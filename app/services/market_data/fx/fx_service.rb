module MarketData
  module Fx
    class FxService
      DEFAULT_TTL = 6.hours

      def initialize(client: Frankfurter::Client.new, cache_store: Rails.cache, fx_rate_model: FxRate)
        @client = client
        @cache_store = cache_store
        @fx_rate_model = fx_rate_model
      end

      def get_rate(base:, quote:)
        base_currency = normalize_currency(base)
        quote_currency = normalize_currency(quote)

        return unavailable(reason: :invalid_currency) if base_currency.blank? || quote_currency.blank?
        return identity_rate(base_currency) if base_currency == quote_currency

        cache_key = "fx:#{base_currency}:#{quote_currency}"
        cached = @cache_store.read(cache_key)
        return cached.deep_symbolize_keys if cached.is_a?(Hash)

        fresh = fetch_and_persist_rate(base_currency: base_currency, quote_currency: quote_currency)
        return write_cache(cache_key, fresh) if fresh[:available]

        fallback = latest_persisted_rate(base_currency: base_currency, quote_currency: quote_currency)
        return write_cache(cache_key, fallback) if fallback[:available]

        fresh
      end

      private

      def fetch_and_persist_rate(base_currency:, quote_currency:)
        payload = @client.get("/v1/latest", params: { base: base_currency, symbols: quote_currency })
        rate = decimal_or_nil(payload&.dig("rates", quote_currency))
        date = parse_date(payload&.dig("date"))

        return unavailable(reason: :request_failed) if rate.nil? || date.nil?

        record = @fx_rate_model.find_or_initialize_by(
          base_currency: base_currency,
          quote_currency: quote_currency,
          rate_date: date
        )
        record.rate = rate
        record.provider = "frankfurter"
        record.retrieved_at = Time.current
        record.save!

        {
          available: true,
          base_currency: base_currency,
          quote_currency: quote_currency,
          rate: rate.to_f,
          fx_date: date,
          provider: "frankfurter",
          retrieved_at: record.retrieved_at.iso8601,
          stale: false
        }
      rescue StandardError => e
        Rails.logger.warn("FxService request failed base=#{base_currency} quote=#{quote_currency} error=#{e.class}: #{e.message}")
        unavailable(reason: :request_failed)
      end

      def latest_persisted_rate(base_currency:, quote_currency:)
        record = @fx_rate_model.for_pair(base_currency, quote_currency).latest_first.first
        return unavailable(reason: :no_fallback) unless record

        {
          available: true,
          base_currency: base_currency,
          quote_currency: quote_currency,
          rate: record.rate.to_f,
          fx_date: record.rate_date,
          provider: record.provider,
          retrieved_at: record.retrieved_at.iso8601,
          stale: true
        }
      end

      def write_cache(key, payload)
        @cache_store.write(key, payload, expires_in: DEFAULT_TTL)
        payload
      end

      def normalize_currency(value)
        code = value.to_s.strip.upcase
        code.match?(/\A[A-Z]{3}\z/) ? code : nil
      end

      def parse_date(value)
        return value if value.is_a?(Date)

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

      def identity_rate(currency)
        {
          available: true,
          base_currency: currency,
          quote_currency: currency,
          rate: 1.0,
          fx_date: Date.current,
          provider: "identity",
          retrieved_at: Time.current.iso8601,
          stale: false
        }
      end

      def unavailable(reason:)
        {
          available: false,
          rate: nil,
          fx_date: nil,
          provider: "frankfurter",
          retrieved_at: nil,
          stale: true,
          reason: reason
        }
      end
    end
  end
end
