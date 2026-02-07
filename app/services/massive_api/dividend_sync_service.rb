module MassiveApi
  class DividendSyncService
    DEFAULT_LOOKBACK_DAYS = 180

    def initialize(wallet:, client: Client.new)
      @wallet = wallet
      @client = client
    end

    def enabled?
      @client.enabled?
    end

    def call(since: DEFAULT_LOOKBACK_DAYS.days.ago.to_date, until_date: Date.current)
      return { synced: 0, skipped: 0, errors: 0 } unless enabled?

      report = { synced: 0, skipped: 0, errors: 0 }

      @wallet.assets.find_each do |asset|
        next if asset.crypto? || asset.fixed_income?

        sync_asset_dividends(asset, since: since, until_date: until_date, report: report)
      end

      report
    end

    private

    def sync_asset_dividends(asset, since:, until_date:, report:)
      data = @client.get(
        "/v3/reference/dividends",
        params: {
          ticker: asset.ticker.to_s.upcase,
          ex_dividend_date_gte: since.to_s,
          ex_dividend_date_lte: until_date.to_s,
          order: "desc",
          sort: "ex_dividend_date",
          limit: 100
        }
      )
      results = data&.dig("results") || []

      results.each do |entry|
        amount = decimal_or_nil(entry["cash_amount"])
        paid_on = parse_date(entry["pay_date"]) || parse_date(entry["ex_dividend_date"])

        if amount.nil? || amount <= 0 || paid_on.nil?
          report[:skipped] += 1
          next
        end

        dividend = @wallet.dividends.find_or_initialize_by(
          asset: asset,
          paid_on: paid_on,
          amount: amount,
          kind: normalize_kind(entry["dividend_type"])
        )
        dividend.reinvested = false if dividend.new_record?

        if dividend.save
          report[:synced] += 1
        else
          report[:errors] += 1
        end
      end
    rescue StandardError => e
      Rails.logger.warn("Massive dividends sync failed asset_id=#{asset.id} error=#{e.class}")
      report[:errors] += 1
    end

    def parse_date(value)
      return if value.blank?

      Date.parse(value)
    rescue Date::Error
      nil
    end

    def decimal_or_nil(value)
      return if value.nil?

      BigDecimal(value.to_s)
    rescue ArgumentError
      nil
    end

    def normalize_kind(dividend_type)
      case dividend_type.to_s.downcase
      when "interest", "coupon"
        dividend_type.to_s.downcase.to_sym
      else
        :dividend
      end
    end
  end
end
