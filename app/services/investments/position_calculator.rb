module Investments
  Position = Struct.new(
    :asset,
    :quantity,
    :avg_price,
    :invested_amount,
    :realized_profit,
    keyword_init: true
  )

  class PositionCalculator
    def initialize(wallet:, asset: nil, as_of: Date.current)
      @wallet = wallet
      @asset = asset
      @as_of = as_of
    end

    def call
      assets = @asset ? [@asset] : @wallet.assets.includes(:investment_transactions)
      assets.map { |asset| calculate_for(asset) }
    end

    private

    def calculate_for(asset)
      quantity = 0.to_d
      avg_price = 0.to_d
      invested_amount = 0.to_d
      realized_profit = 0.to_d

      asset.investment_transactions
        .where("occurred_on <= ?", @as_of)
        .ordered
        .find_each do |transaction|
          case transaction.kind
          when "buy"
            total_cost = (avg_price * quantity) + (transaction.quantity * transaction.price) + transaction.fees
            quantity += transaction.quantity
            avg_price = quantity.positive? ? total_cost / quantity : 0.to_d
            invested_amount = avg_price * quantity
          when "sell"
            proceeds = (transaction.quantity * transaction.price) - transaction.fees
            cost_basis = transaction.quantity * avg_price
            realized_profit += proceeds - cost_basis
            quantity -= transaction.quantity
            quantity = 0.to_d if quantity.negative?
            invested_amount = avg_price * quantity
          end
        end

      Position.new(
        asset: asset,
        quantity: quantity,
        avg_price: avg_price,
        invested_amount: invested_amount,
        realized_profit: realized_profit
      )
    end
  end
end
