require "set"

module Frankfurter
  class MarketDataService
    CACHE_TTL_MINUTES = 15
    CURRENCIES_CACHE_TTL_HOURS = 24
    LIVE_CACHE_SECONDS = 20

    def initialize(client: Client.new)
      @client = client
    end

    def enabled?
      @client.enabled? && supported_currencies.any?
    end

    def quote_currency
      resolve_quote_currency
    end

    def currencies
      payload = @client.get("/v1/currencies")
      return {} unless payload.is_a?(Hash)

      payload.transform_keys { |code| code.to_s.upcase }
    rescue StandardError
      {}
    end

    def quotes_for(assets:)
      assets.each_with_object({}) do |asset, quotes|
        quotes[asset.id] = quote_for(asset)
      end
    end

    def histories_for(assets:, days: 90)
      assets.each_with_object({}) do |asset, histories|
        histories[asset.id] = history_for(asset, days: days)
      end
    end

    def latest_rates(base:, symbols:)
      base_currency = base.to_s.strip.upcase
      target_symbols = Array(symbols).map { |symbol| symbol.to_s.strip.upcase }.reject(&:blank?).uniq
      return unavailable_latest_rates(reason: :invalid_base) if base_currency.blank?
      return unavailable_latest_rates(reason: :invalid_symbols) if target_symbols.empty?
      return unavailable_latest_rates(reason: :unsupported_currency) unless supported_currency?(base_currency)

      valid_symbols = target_symbols.select { |symbol| supported_currency?(symbol) && symbol != base_currency }
      return unavailable_latest_rates(reason: :unsupported_currency) if valid_symbols.empty?

      cache_key = "frankfurter:live:#{base_currency}:#{valid_symbols.sort.join(',')}"
      expires_in = ENV.fetch("FRANKFURTER_LIVE_CACHE_SECONDS", LIVE_CACHE_SECONDS).to_i.seconds
      Rails.cache.fetch(cache_key, expires_in: expires_in) do
        fetch_latest_rates(base_currency: base_currency, symbols: valid_symbols)
      end
    end

    def quote_for(asset)
      from_currency = resolve_base_currency(asset)
      return unavailable_quote(reason: :unsupported_currency, ticker: asset.ticker) if from_currency.blank?
      return unavailable_quote(reason: :unsupported_currency, ticker: asset.ticker) unless supported_currency?(from_currency)

      to_currency = resolve_quote_currency
      return unavailable_quote(reason: :unsupported_currency, ticker: asset.ticker) unless supported_currency?(to_currency)
      if from_currency == to_currency
        return {
          ticker: asset.ticker,
          name: asset.name,
          from_currency: from_currency,
          currency: to_currency,
          exchange_rate: BigDecimal("1"),
          close_date: Date.current,
          source: :frankfurter,
          available: true
        }
      end

      cache_key = "frankfurter:quote:#{from_currency}:#{to_currency}"
      expires_in = ENV.fetch("FRANKFURTER_CACHE_MINUTES", CACHE_TTL_MINUTES).to_i.minutes
      Rails.cache.fetch(cache_key, expires_in: expires_in) { fetch_quote(from_currency: from_currency, to_currency: to_currency, asset: asset) }
    end

    def history_for(asset, days: 90)
      from_currency = resolve_base_currency(asset)
      return unavailable_history(reason: :unsupported_currency) if from_currency.blank?
      return unavailable_history(reason: :unsupported_currency) unless supported_currency?(from_currency)

      to_currency = resolve_quote_currency
      return unavailable_history(reason: :unsupported_currency) unless supported_currency?(to_currency)
      if from_currency == to_currency
        points = Array.new(days, 1.0)
        return { available: true, points: points, trend: :flat }
      end

      cache_key = "frankfurter:history:#{from_currency}:#{to_currency}:#{days}"
      expires_in = ENV.fetch("FRANKFURTER_CACHE_MINUTES", CACHE_TTL_MINUTES).to_i.minutes
      Rails.cache.fetch(cache_key, expires_in: expires_in) { fetch_history(from_currency: from_currency, to_currency: to_currency, days: days) }
    end

    private

    def fetch_quote(from_currency:, to_currency:, asset:)
      payload = @client.get("/v1/latest", params: { base: from_currency, symbols: to_currency })
      rate = decimal_or_nil(payload&.dig("rates", to_currency))

      {
        ticker: asset.ticker,
        name: asset.name,
        from_currency: from_currency,
        currency: to_currency,
        exchange_rate: rate,
        close_date: parse_date(payload&.dig("date")),
        source: :frankfurter,
        available: rate.present?
      }
    rescue StandardError => e
      Rails.logger.warn("Frankfurter quote failed asset_id=#{asset.id} ticker=#{asset.ticker} error=#{e.class}")
      unavailable_quote(reason: :request_failed, ticker: asset.ticker)
    end

    def fetch_history(from_currency:, to_currency:, days:)
      from = days.days.ago.to_date.to_s
      to = Date.current.to_s
      payload = @client.get("/v1/#{from}..#{to}", params: { base: from_currency, symbols: to_currency })
      rates_by_date = payload&.dig("rates") || {}

      points = rates_by_date.sort_by { |date, _| date }.map do |_, rates|
        decimal_or_nil(rates[to_currency])
      end.compact

      return unavailable_history(reason: :empty_series) if points.empty?

      first = points.first
      last = points.last
      trend = if last > first
                :up
              elsif last < first
                :down
              else
                :flat
              end

      {
        available: true,
        points: points.map(&:to_f),
        trend: trend
      }
    rescue StandardError => e
      Rails.logger.warn("Frankfurter history failed from=#{from_currency} to=#{to_currency} error=#{e.class}")
      unavailable_history(reason: :request_failed)
    end

    def fetch_latest_rates(base_currency:, symbols:)
      payload = @client.get("/v1/latest", params: { base: base_currency, symbols: symbols.join(",") })
      rates_payload = payload&.dig("rates")
      return unavailable_latest_rates(reason: :request_failed) unless rates_payload.is_a?(Hash)

      rates = symbols.filter_map do |symbol|
        rate = decimal_or_nil(rates_payload[symbol])
        next if rate.nil? || rate <= 0

        {
          symbol: symbol,
          rate: rate.to_f,
          inverse_rate: (BigDecimal("1") / rate).round(6).to_f
        }
      end

      return unavailable_latest_rates(reason: :empty_rates) if rates.empty?

      {
        available: true,
        base: base_currency,
        date: parse_date(payload["date"]),
        updated_at: Time.current.iso8601,
        rates: rates,
        source: :frankfurter
      }
    rescue StandardError => e
      Rails.logger.warn("Frankfurter live rates failed base=#{base_currency} symbols=#{symbols.join(',')} error=#{e.class}")
      unavailable_latest_rates(reason: :request_failed)
    end

    def resolve_base_currency(asset)
      currency = asset.currency.to_s.strip.upcase
      return currency if currency.match?(/\A[A-Z]{3}\z/)

      nil
    end

    def resolve_quote_currency
      ENV.fetch("FRANKFURTER_QUOTE_CURRENCY", "BRL").to_s.upcase
    end

    def supported_currency?(currency_code)
      supported_currencies.include?(currency_code)
    end

    def supported_currencies
      cache_key = "frankfurter:currencies"
      expires_in = CURRENCIES_CACHE_TTL_HOURS.hours
      Rails.cache.fetch(cache_key, expires_in: expires_in) do
        payload = @client.get("/v1/currencies")
        payload.is_a?(Hash) ? payload.keys.map(&:to_s).map(&:upcase).to_set : Set.new
      end
    end

    def parse_date(value)
      Date.parse(value.to_s)
    rescue ArgumentError, TypeError
      nil
    end

    def decimal_or_nil(value)
      return nil if value.nil?
      BigDecimal(value.to_s)
    rescue ArgumentError
      nil
    end

    def unavailable_quote(reason:, ticker:)
      {
        ticker: ticker,
        name: nil,
        from_currency: nil,
        currency: nil,
        exchange_rate: nil,
        close_date: nil,
        source: :frankfurter,
        available: false,
        reason: reason
      }
    end

    def unavailable_history(reason:)
      {
        available: false,
        points: [],
        trend: :flat,
        reason: reason
      }
    end

    def unavailable_latest_rates(reason:)
      {
        available: false,
        base: nil,
        date: nil,
        updated_at: nil,
        rates: [],
        source: :frankfurter,
        reason: reason
      }
    end
  end
end
