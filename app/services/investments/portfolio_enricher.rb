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
        market_price = quote[:market_price].to_d if quote[:market_price].present?
        current_value = market_price ? market_price * position.quantity : nil
        unrealized_profit = current_value ? current_value - position.invested_amount : nil

        EnrichedPosition.new(
          position: position,
          market_price: market_price,
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
