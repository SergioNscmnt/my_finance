require "json"
require "net/http"
require "uri"

module Frankfurter
  class Client
    DEFAULT_TIMEOUT = 5

    def initialize(
      base_url: ENV.fetch("FRANKFURTER_API_BASE_URL", "https://api.frankfurter.dev"),
      timeout: ENV.fetch("FRANKFURTER_API_TIMEOUT", DEFAULT_TIMEOUT).to_i
    )
      @base_url = base_url
      @timeout = timeout
    end

    def enabled?
      true
    end

    def get(path, params: {})
      uri = build_uri(path, params)
      request = Net::HTTP::Get.new(uri)
      request["Accept"] = "application/json"

      response = perform_request(uri, request)
      return nil unless response
      return parse_json(response.body) if response.is_a?(Net::HTTPSuccess)

      Rails.logger.warn("Frankfurter request failed path=#{path} status=#{response.code}")
      nil
    rescue StandardError => e
      Rails.logger.error("Frankfurter error path=#{path} error=#{e.class}: #{e.message}")
      nil
    end

    private

    def build_uri(path, params)
      uri =
        if path.to_s.match?(/\Ahttps?:\/\//)
          URI.parse(path.to_s)
        else
          URI.join(@base_url, path.to_s)
        end

      existing_params = URI.decode_www_form(uri.query.to_s).to_h
      query_params = existing_params.merge(params.compact.transform_keys(&:to_s))
      uri.query = URI.encode_www_form(query_params)
      uri
    end

    def perform_request(uri, request)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", read_timeout: @timeout, open_timeout: @timeout) do |http|
        http.request(request)
      end
    end

    def parse_json(body)
      JSON.parse(body)
    rescue JSON::ParserError
      nil
    end
  end
end
