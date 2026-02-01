module Investments
  class PerformanceCalculator
    def initialize(wallet:, positions:)
      @wallet = wallet
      @positions = positions
    end

    def call
      invested_total = @positions.sum(&:invested_amount)
      realized_profit = @positions.sum(&:realized_profit)
      dividends_total = @wallet.dividends.sum(:amount)

      {
        invested_total: invested_total,
        realized_profit: realized_profit,
        dividends_total: dividends_total,
        total_result: realized_profit + dividends_total
      }
    end
  end
end
