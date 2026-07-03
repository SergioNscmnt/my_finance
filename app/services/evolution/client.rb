require "json"
require "net/http"

module Evolution
  class Client
    class ConfigurationError < StandardError; end
    class RequestError < StandardError; end

    def initialize(
      base_url: ENV["EVOLUTION_API_BASE_URL"],
      api_key: ENV["EVOLUTION_API_KEY"],
      default_instance: ENV["EVOLUTION_INSTANCE_NAME"],
      timeout: 10
    )
      @base_url = base_url.to_s.delete_suffix("/")
      @api_key = api_key.to_s
      @default_instance = default_instance.to_s
      @timeout = timeout
    end

    def configured?
      @base_url.present? && @api_key.present?
    end

    def send_text(number:, text:, instance_name: @default_instance)
      ensure_configured!(instance_name)

      uri = URI("#{@base_url}/message/sendText/#{instance_name}")
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request["apikey"] = @api_key
      request.body = {
        number: number.to_s,
        textMessage: { text: text.to_s }
      }.to_json

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", read_timeout: @timeout, open_timeout: @timeout) do |http|
        http.request(request)
      end

      return response if response.is_a?(Net::HTTPSuccess)

      raise RequestError, "Evolution API respondeu #{response.code}: #{response.body.to_s.truncate(300)}"
    end

    private

    def ensure_configured!(instance_name)
      raise ConfigurationError, "EVOLUTION_API_BASE_URL não configurada" if @base_url.blank?
      raise ConfigurationError, "EVOLUTION_API_KEY não configurada" if @api_key.blank?
      raise ConfigurationError, "EVOLUTION_INSTANCE_NAME não configurada" if instance_name.blank?
    end
  end
end
