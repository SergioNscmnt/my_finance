class Candle < ApplicationRecord
  belongs_to :asset

  validates :timeframe, presence: true
  validates :timestamp, presence: true
  validates :open, :high, :low, :close, numericality: { greater_than_or_equal_to: 0 }
  validates :volume, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :timestamp, uniqueness: { scope: %i[asset_id timeframe] }
end
