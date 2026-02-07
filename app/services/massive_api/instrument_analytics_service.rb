require "cgi"

module MassiveApi
  class InstrumentAnalyticsService
    def initialize(client: Client.new)
      @client = client
    end

    def snapshot(instrument)
      ticker = instrument.ticker.to_s.upcase
      prev_payload = @client.get("/v2/aggs/ticker/#{CGI.escape(ticker)}/prev", params: { adjusted: "true" }) || {}
      prev_result = prev_payload.dig("results", 0) || {}
      current_price = decimal_or_nil(prev_result["c"])
      previous_close = decimal_or_nil(prev_result["o"])

      from = 2.years.ago.to_date.to_s
      to = Date.current.to_s
      history_payload = @client.get("/v2/aggs/ticker/#{CGI.escape(ticker)}/range/1/day/#{from}/#{to}", params: { adjusted: "true", sort: "asc", limit: 5000 }) || {}
      history_rows = history_payload["results"] || []

      chart_labels = history_rows.map { |row| Time.zone.at(row["t"].to_i / 1000).to_date.strftime("%b/%y") }
      chart_values = history_rows.map { |row| row["c"].to_f }

      first_price = chart_values.first.to_d
      last_price = chart_values.last.to_d
      change_pct = if first_price.positive?
                     (((last_price - first_price) / first_price) * 100).round(2)
                   else
                     0.to_d
                   end

      {
        ticker: ticker,
        current_price: current_price,
        previous_close: previous_close,
        change_pct: change_pct,
        chart_labels: chart_labels,
        chart_values: chart_values
      }
    end

    private

    def decimal_or_nil(value)
      return if value.nil?

      BigDecimal(value.to_s)
    rescue ArgumentError
      nil
    end
  end
end
