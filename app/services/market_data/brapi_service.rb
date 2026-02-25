require "json"
require "net/http"
require "uri"

module MarketData
  class BrapiService
    DEFAULT_TIMEOUT = 5
    BASE_URL = "https://brapi.dev"

    def initialize(timeout: ENV.fetch("BRAPI_TIMEOUT", DEFAULT_TIMEOUT).to_i)
      @timeout = timeout
    end

    def search_tickers(query:, limit: 20)
      q = query.to_s.strip
      return [] if q.blank?

      payload = get("/api/quote/list", params: { search: q })
      rows = payload&.dig("stocks")
      return [] unless rows.is_a?(Array)

      rows.first(limit.to_i).filter_map do |row|
        symbol = row["stock"].to_s.strip.upcase
        name = row["name"].to_s.strip
        next if symbol.blank? || name.blank?

        {
          symbol: symbol,
          name: name,
          exchange: "B3",
          type: row["type"].to_s,
          currency: "BRL",
          asset_type: map_asset_type(row["type"].to_s)
        }
      end
    rescue StandardError => e
      Rails.logger.warn("Brapi search failed query=#{q} error=#{e.class}")
      []
    end

    def quote_for_asset(asset)
      symbol = asset.ticker.to_s.strip.upcase
      return unavailable_quote(reason: :invalid_ticker) if symbol.blank?

      payload = get("/api/quote/#{URI.encode_www_form_component(symbol)}")
      row = payload&.dig("results", 0)
      return unavailable_quote(reason: :not_found) unless row.is_a?(Hash)

      price = decimal_or_nil(row["regularMarketPrice"])
      return unavailable_quote(reason: :unavailable_price) unless price

      {
        available: true,
        symbol: row["symbol"].to_s.upcase.presence || symbol,
        name: row["shortName"].presence || row["longName"].presence || asset.name,
        currency: row["currency"].to_s.upcase.presence || asset.currency.to_s.upcase,
        market_price: price,
        change_percent: decimal_or_nil(row["regularMarketChangePercent"]),
        market_time: parse_time(row["regularMarketTime"]),
        source: :brapi
      }
    rescue StandardError => e
      Rails.logger.warn("Brapi quote failed asset_id=#{asset.id} ticker=#{asset.ticker} error=#{e.class}")
      unavailable_quote(reason: :request_failed)
    end

    private

    def map_asset_type(type)
      normalized = type.to_s.strip.downcase

      case normalized
      when "stock", "bdr", "equity", "acao", "ações", "acoes", "unit"
        :stock
      when "fii", "reit", "real estate", "real estate fund", "fundo imobiliario", "fundo imobiliário"
        :fii
      when "fund", "funds", "etf", "mutual fund", "investment fund", "fundo"
        :fund
      when "crypto", "cryptocurrency"
        :crypto
      else
        nil
      end
    end

    def get(path, params: {})
      uri = URI.join(BASE_URL, path)
      uri.query = URI.encode_www_form(params.compact.transform_keys(&:to_s)) if params.present?
      request = Net::HTTP::Get.new(uri)
      request["Accept"] = "application/json"

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: @timeout, open_timeout: @timeout) do |http|
        http.request(request)
      end
      return nil unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end

    def parse_time(value)
      return nil if value.blank?

      if value.is_a?(Numeric) || value.to_s.match?(/\A\d+\z/)
        return Time.zone.at(value.to_i)
      end

      Time.zone.parse(value.to_s)
    rescue ArgumentError
      nil
    end

    def decimal_or_nil(value)
      return nil if value.nil?
      BigDecimal(value.to_s)
    rescue ArgumentError
      nil
    end

    def unavailable_quote(reason:)
      {
        available: false,
        symbol: nil,
        name: nil,
        currency: nil,
        market_price: nil,
        change_percent: nil,
        market_time: nil,
        source: :brapi,
        reason: reason
      }
    end
  end
end
