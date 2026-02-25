module Investments
  EnrichedPosition = Struct.new(
    :position,
    :market_price,
    :current_value,
    :unrealized_profit,
    :quote_currency,
    :quote_date,
    :quote_available,
    keyword_init: true
  )

  class PortfolioEnricher
    def initialize(positions:, quotes_by_asset_id:)
      @positions = positions
      @quotes_by_asset_id = quotes_by_asset_id || {}
    end

    def call
      @positions.map do |position|
        quote = @quotes_by_asset_id[position.asset.id] || {}
        exchange_rate = quote[:exchange_rate].to_d if quote[:exchange_rate].present?
        converted_unit_price = exchange_rate ? position.avg_price.to_d * exchange_rate : nil
        converted_invested_amount = exchange_rate ? position.invested_amount.to_d * exchange_rate : nil
        current_value = converted_unit_price ? converted_unit_price * position.quantity : nil
        unrealized_profit = current_value && converted_invested_amount ? current_value - converted_invested_amount : nil

        EnrichedPosition.new(
          position: position,
          market_price: converted_unit_price,
          current_value: current_value,
          unrealized_profit: unrealized_profit,
          quote_currency: quote[:currency],
          quote_date: quote[:close_date],
          quote_available: quote[:available] == true
        )
      end
    end
  end
end
