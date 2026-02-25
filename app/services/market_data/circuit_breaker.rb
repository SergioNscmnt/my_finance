module MarketData
  class CircuitBreaker
    def initialize(cache_store: Rails.cache, key:, failure_threshold: 5, window_seconds: 60, cooldown_seconds: 30)
      @cache_store = cache_store
      @state_key = "circuit_breaker:#{key}"
      @failure_threshold = failure_threshold
      @window_seconds = window_seconds
      @cooldown_seconds = cooldown_seconds
    end

    def allow_request?
      !open?
    end

    def open?
      state = current_state
      open_until = state[:open_until]
      open_until.present? && open_until > Time.current.to_f
    end

    def record_success
      @cache_store.delete(@state_key)
    end

    def record_failure
      now = Time.current.to_f
      state = current_state
      failures = Array(state[:failures]).select { |ts| ts >= now - @window_seconds }
      failures << now

      open_until = state[:open_until]
      open_until = now + @cooldown_seconds if failures.size >= @failure_threshold

      persist_state(failures: failures, open_until: open_until)
    end

    private

    def current_state
      state = @cache_store.read(@state_key)
      return { failures: [], open_until: nil } unless state.is_a?(Hash)

      {
        failures: Array(state[:failures]).map(&:to_f),
        open_until: state[:open_until]&.to_f
      }
    end

    def persist_state(failures:, open_until:)
      ttl = [@window_seconds, @cooldown_seconds].max * 2
      @cache_store.write(
        @state_key,
        { failures: failures, open_until: open_until },
        expires_in: ttl.seconds
      )
    end
  end
end
