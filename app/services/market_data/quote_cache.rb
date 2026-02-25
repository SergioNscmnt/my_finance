require "json"

module MarketData
  class QuoteCache
    DEFAULT_TTL = 30.seconds

    def initialize(cache_store: Rails.cache, key_prefix: "quote")
      @cache_store = cache_store
      @key_prefix = key_prefix
    end

    def write(asset_id:, payload:, ttl: DEFAULT_TTL)
      @cache_store.write(cache_key(asset_id), normalize_payload(payload), expires_in: ttl)
    end

    def read(asset_id)
      payload = @cache_store.read(cache_key(asset_id))
      payload.is_a?(Hash) ? payload.deep_symbolize_keys : nil
    end

    def read_many(asset_ids)
      ids = Array(asset_ids).map(&:to_i).uniq
      return {} if ids.empty?

      keys_by_id = ids.index_with { |id| cache_key(id) }
      raw = @cache_store.read_multi(*keys_by_id.values)

      ids.each_with_object({}) do |id, acc|
        payload = raw[keys_by_id[id]]
        acc[id] = payload.deep_symbolize_keys if payload.is_a?(Hash)
      end
    end

    private

    def cache_key(asset_id)
      "#{@key_prefix}:#{asset_id}"
    end

    def normalize_payload(payload)
      data = payload.deep_symbolize_keys

      {
        asset_id: data[:asset_id].to_i,
        price: decimal_or_nil(data[:price])&.to_f,
        change_percent: decimal_or_nil(data[:change_percent])&.to_f,
        provider: data[:provider].to_s.presence,
        provider_timestamp: to_iso8601(data[:provider_timestamp]),
        retrieved_at: to_iso8601(data[:retrieved_at]),
        stale: !!data[:stale]
      }.compact
    end

    def decimal_or_nil(value)
      return nil if value.nil?

      BigDecimal(value.to_s)
    rescue ArgumentError
      nil
    end

    def to_iso8601(value)
      return value.iso8601 if value.respond_to?(:iso8601)
      return nil if value.blank?

      Time.zone.parse(value.to_s)&.iso8601
    rescue ArgumentError
      nil
    end
  end
end
