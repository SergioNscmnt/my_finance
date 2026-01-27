require "net/http"
require "json"

module Ai
  class OllamaClient
    class Error < StandardError; end

    def initialize(base_url: nil, model: nil, timeout: nil)
      @base_url = base_url || ENV.fetch("OLLAMA_URL", "http://localhost:11434")
      @model = model || ENV.fetch("OLLAMA_MODEL", "llama3.1:8b")
      @timeout = (timeout || ENV.fetch("OLLAMA_TIMEOUT", "15")).to_i
    end

    def chat(messages)
      uri = URI.join(@base_url, "/api/chat")
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request.body = JSON.dump({ model: @model, messages: messages, stream: false })

      response = http_client(uri).request(request)
      raise Error, "HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      json = JSON.parse(response.body)
      content = json.dig("message", "content").to_s
      raise Error, "Empty response" if content.strip.empty?

      content
    rescue JSON::ParserError => error
      raise Error, "Invalid JSON: #{error.message}"
    rescue StandardError => error
      raise Error, error.message
    end

    private

    def http_client(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = @timeout
      http.read_timeout = @timeout
      http
    end
  end
end
