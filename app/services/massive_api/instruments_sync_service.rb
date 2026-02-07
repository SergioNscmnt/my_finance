module MassiveApi
  class InstrumentsSyncService
    PAGE_LIMIT = 1000
    DEFAULT_MAX_PAGES = 30

    def initialize(client: Client.new)
      @client = client
    end

    def enabled?
      @client.enabled?
    end

    def call
      return { synced: 0, skipped: 0, pages: 0 } unless enabled?

      report = { synced: 0, skipped: 0, pages: 0 }
      sync_market!("stocks", report)
      sync_market!("crypto", report)
      report
    end

    private

    def sync_market!(market, report)
      pages = 0
      max_pages = ENV.fetch("MASSIVE_INSTRUMENT_SYNC_MAX_PAGES", DEFAULT_MAX_PAGES).to_i
      next_url = nil

      loop do
        payload =
          if next_url.present?
            @client.get(next_url) || {}
          else
            @client.get("/v3/reference/tickers", params: {
              market: market,
              active: "true",
              order: "asc",
              sort: "ticker",
              limit: PAGE_LIMIT
            }) || {}
          end
        results = payload["results"] || []
        break if results.empty?

        results.each do |row|
          attrs = normalized_attrs(row, market)
          if attrs.nil?
            report[:skipped] += 1
            next
          end

          instrument = MarketInstrument.find_or_initialize_by(ticker: attrs[:ticker])
          instrument.assign_attributes(attrs.merge(active: true, last_synced_at: Time.current))
          instrument.save!
          report[:synced] += 1
        end

        pages += 1
        report[:pages] += 1
        next_url = payload["next_url"]
        break if pages >= max_pages
        break if next_url.blank?
      end
    end

    def normalized_attrs(row, market)
      ticker = row["ticker"].to_s.upcase
      name = row["name"].to_s
      return nil if ticker.blank? || name.blank?

      type = asset_type_from(row, market)
      return nil unless type

      {
        ticker: ticker,
        name: name,
        asset_type: type,
        market: (row["market"] || market).to_s,
        locale: row["locale"],
        currency: row["currency_name"].presence || (market == "crypto" ? "USD" : "USD")
      }
    end

    def asset_type_from(row, market)
      ticker = row["ticker"].to_s.upcase
      api_type = row["type"].to_s.upcase

      return :crypto if market == "crypto" || ticker.start_with?("X:")
      return :fund if %w[ETF ETN MF CEF FUND].include?(api_type)
      return :stock if market == "stocks"

      nil
    end
  end
end
