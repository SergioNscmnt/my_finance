require "cgi"

module MassiveApi
  class MarketDataService
    CACHE_TTL_MINUTES = 15

    def initialize(client: Client.new)
      @client = client
    end

    def enabled?
      @client.enabled?
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

    def quote_for(asset)
      return unavailable_quote(reason: :unsupported_asset_type, ticker: asset.ticker) if unsupported_asset_type?(asset)

      cache_key = "massive:quote:#{asset.id}:#{asset.ticker}:#{asset.updated_at.to_i}"
      expires_in = ENV.fetch("MASSIVE_API_CACHE_MINUTES", CACHE_TTL_MINUTES).to_i.minutes
      Rails.cache.fetch(cache_key, expires_in: expires_in) { fetch_quote_for(asset) }
    end

    def history_for(asset, days: 90)
      return unavailable_history(reason: :unsupported_asset_type) if unsupported_asset_type?(asset)

      cache_key = "massive:history:#{asset.id}:#{asset.ticker}:#{days}:#{asset.updated_at.to_i}"
      expires_in = ENV.fetch("MASSIVE_API_CACHE_MINUTES", CACHE_TTL_MINUTES).to_i.minutes
      Rails.cache.fetch(cache_key, expires_in: expires_in) { fetch_history_for(asset, days: days) }
    end

    private

    def fetch_quote_for(asset)
      massive_ticker = normalize_ticker(asset)
      return unavailable_quote(reason: :unsupported_ticker, ticker: massive_ticker) if massive_ticker.blank?

      prev = @client.get("/v2/aggs/ticker/#{CGI.escape(massive_ticker)}/prev", params: { adjusted: "true" })
      result = prev&.dig("results", 0) || {}
      price = decimal_or_nil(result["c"])

      details = @client.get("/v3/reference/tickers/#{CGI.escape(massive_ticker)}")

      {
        ticker: massive_ticker,
        name: details&.dig("results", "name") || asset.name,
        currency: details&.dig("results", "currency_name") || asset.currency,
        market_price: price,
        close_date: result["t"] ? Time.zone.at(result["t"].to_i / 1000).to_date : nil,
        source: :massive,
        available: price.present?
      }
    rescue StandardError => e
      Rails.logger.warn("Massive quote failed asset_id=#{asset.id} ticker=#{asset.ticker} error=#{e.class}")
      unavailable_quote(reason: :request_failed, ticker: massive_ticker)
    end

    def fetch_history_for(asset, days: 90)
      massive_ticker = normalize_ticker(asset)
      return unavailable_history(reason: :unsupported_ticker) if massive_ticker.blank?

      from = days.days.ago.to_date.to_s
      to = Date.current.to_s
      payload = @client.get(
        "/v2/aggs/ticker/#{CGI.escape(massive_ticker)}/range/1/day/#{from}/#{to}",
        params: { adjusted: "true", sort: "asc", limit: 5000 }
      )
      rows = payload&.dig("results") || []
      closes = rows.map { |row| decimal_or_nil(row["c"]) }.compact

      return unavailable_history(reason: :empty_series) if closes.empty?

      first = closes.first
      last = closes.last
      trend = if last > first
                :up
              elsif last < first
                :down
              else
                :flat
              end

      {
        available: true,
        points: closes.map(&:to_f),
        trend: trend
      }
    rescue StandardError => e
      Rails.logger.warn("Massive history failed asset_id=#{asset.id} ticker=#{asset.ticker} error=#{e.class}")
      unavailable_history(reason: :request_failed)
    end

    def normalize_ticker(asset)
      ticker = asset.ticker.to_s.strip.upcase
      return if ticker.blank?

      if asset.crypto?
        return ticker if ticker.start_with?("X:")
        quote_currency = ENV.fetch("MASSIVE_API_CRYPTO_QUOTE_CURRENCY", "USD").upcase
        return "X:#{ticker}#{quote_currency}" if ticker.match?(/\A[A-Z0-9]+\z/)
      end

      ticker
    end

    def unsupported_asset_type?(asset)
      asset.fixed_income?
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
        currency: nil,
        market_price: nil,
        close_date: nil,
        source: :massive,
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
  end
end
