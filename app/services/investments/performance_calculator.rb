module Investments
  class PerformanceCalculator
    def initialize(wallet:, positions:, enriched_positions: [])
      @wallet = wallet
      @positions = positions
      @enriched_positions = enriched_positions
    end

    def call
      invested_total = @positions.sum(&:invested_amount)
      realized_profit = @positions.sum(&:realized_profit)
      dividends_total = @wallet.dividends.sum(:amount)
      market_value_total = @enriched_positions.sum { |position| position.current_value.to_d }
      unrealized_profit = @enriched_positions.sum { |position| position.unrealized_profit.to_d }

      {
        invested_total: invested_total,
        market_value_total: market_value_total,
        realized_profit: realized_profit,
        unrealized_profit: unrealized_profit,
        dividends_total: dividends_total,
        total_result: realized_profit + dividends_total + unrealized_profit
      }
    end
  end
end
