module Investments
  class AllocationCalculator
    def initialize(positions:)
      @positions = positions
    end

    def call
      totals = Hash.new(0.to_d)
      total_invested = 0.to_d

      @positions.each do |position|
        amount = position.invested_amount
        totals[position.asset.asset_type] += amount
        total_invested += amount
      end

      totals.transform_values do |amount|
        total_invested.positive? ? (amount / total_invested) : 0.to_d
      end
    end
  end
end
