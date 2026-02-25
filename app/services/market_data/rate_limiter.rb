module MarketData
  class RateLimiter
    DEFAULT_CAPACITY = 50
    DEFAULT_REFILL_RATE = 10.0

    def initialize(cache_store: Rails.cache, key:, capacity: DEFAULT_CAPACITY, refill_rate_per_second: DEFAULT_REFILL_RATE)
      @cache_store = cache_store
      @key = "rate_limiter:#{key}"
      @capacity = capacity.to_f
      @refill_rate = refill_rate_per_second.to_f
    end

    def allow?(tokens: 1.0)
      requested = tokens.to_f
      return false if requested <= 0 || requested > @capacity

      bucket = current_bucket
      refill!(bucket)

      return false if bucket[:tokens] < requested

      bucket[:tokens] -= requested
      persist_bucket(bucket)
      true
    end

    private

    def current_bucket
      state = @cache_store.read(@key)
      return default_bucket unless state.is_a?(Hash)

      {
        tokens: state[:tokens].to_f,
        updated_at: state[:updated_at].to_f
      }
    end

    def default_bucket
      {
        tokens: @capacity,
        updated_at: monotonic_now
      }
    end

    def refill!(bucket)
      elapsed = monotonic_now - bucket[:updated_at]
      return if elapsed <= 0

      bucket[:tokens] = [@capacity, bucket[:tokens] + (elapsed * @refill_rate)].min
      bucket[:updated_at] = monotonic_now
    end

    def persist_bucket(bucket)
      ttl = [(@capacity / [@refill_rate, 0.001].max).ceil * 2, 60].max
      @cache_store.write(@key, bucket, expires_in: ttl.seconds)
    end

    def monotonic_now
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end
