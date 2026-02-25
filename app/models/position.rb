class Position < ApplicationRecord
  belongs_to :portfolio
  belongs_to :asset

  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :avg_cost, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true, length: { is: 3 }
  validates :asset_id, uniqueness: { scope: :portfolio_id }

  before_validation :normalize_currency

  private

  def normalize_currency
    self.currency = currency.to_s.strip.upcase
  end
end
