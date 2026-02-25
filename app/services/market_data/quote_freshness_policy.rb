module MarketData
  class QuoteFreshnessPolicy
    OPEN_TTL = 30.seconds
    CLOSED_TTL = 15.minutes

    def initialize(now: Time.current)
      @now = now
    end

    def stale?(provider_timestamp:, retrieved_at:)
      retrieval_time = cast_time(retrieved_at)
      return true unless retrieval_time

      ttl = open_market?(provider_timestamp, retrieval_time) ? OPEN_TTL : CLOSED_TTL
      retrieval_time < @now - ttl
    end

    private

    def open_market?(provider_timestamp, retrieved_at)
      provider_time = cast_time(provider_timestamp)
      return false unless provider_time

      # Heurística MVP: provider timestamp recente e se movendo próximo da captura.
      provider_time >= @now - 2.minutes && (retrieved_at - provider_time).abs <= 5.minutes
    end

    def cast_time(value)
      return value if value.is_a?(Time) || value.is_a?(ActiveSupport::TimeWithZone)
      return nil if value.blank?

      Time.zone.parse(value.to_s)
    rescue ArgumentError
      nil
    end
  end
end
