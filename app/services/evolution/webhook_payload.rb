require "digest"

module Evolution
  class WebhookPayload
    attr_reader :raw

    def initialize(raw)
      @raw = raw.deep_stringify_keys
    end

    def event_name
      raw["event"].presence || raw.dig("body", "event").presence || "unknown"
    end

    def instance_name
      raw["instance"].presence || raw.dig("body", "instance").presence || raw.dig("data", "instance").presence || ENV["EVOLUTION_INSTANCE_NAME"].to_s
    end

    def message_id
      raw.dig("data", "key", "id").presence ||
        raw.dig("key", "id").presence ||
        raw.dig("data", "id").presence ||
        raw["id"].presence ||
        Digest::SHA256.hexdigest(raw.to_json)
    end

    def sender_phone
      jid = raw.dig("data", "key", "remoteJid").presence ||
            raw.dig("key", "remoteJid").presence ||
            raw.dig("data", "remoteJid").presence ||
            raw.dig("data", "sender").presence ||
            raw["sender"].presence ||
            raw.dig("data", "from").presence ||
            raw["from"].presence

      WhatsappAccount.normalize_phone(jid.to_s.split("@").first)
    end

    def from_me?
      raw.dig("data", "key", "fromMe") == true || raw.dig("key", "fromMe") == true
    end

    def message_type
      raw.dig("data", "messageType").presence ||
        raw["messageType"].presence ||
        message.keys.first.to_s.presence
    end

    def message_text
      [
        message["conversation"],
        message.dig("extendedTextMessage", "text"),
        message.dig("imageMessage", "caption"),
        message.dig("videoMessage", "caption"),
        raw.dig("data", "message", "text"),
        raw.dig("data", "text"),
        raw["text"]
      ].compact.find(&:present?).to_s.strip
    end

    def occurred_on
      timestamp = raw.dig("data", "messageTimestamp").presence || raw["messageTimestamp"].presence || raw.dig("data", "timestamp").presence
      return Date.current if timestamp.blank?

      Time.zone.at(timestamp.to_i).to_date
    rescue ArgumentError, TypeError
      Date.current
    end

    def media?
      message_type.to_s.include?("image") || message_type.to_s.include?("video") || message_type.to_s.include?("document")
    end

    private

    def message
      raw.dig("data", "message").presence || raw["message"].presence || {}
    end
  end
end
