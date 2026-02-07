class MarketInstrument < ApplicationRecord
  enum asset_type: { stock: 0, fund: 1, crypto: 2 }

  validates :ticker, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true
  validates :asset_type, presence: true
  validates :currency, presence: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:ticker) }
end
