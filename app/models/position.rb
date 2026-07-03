class Position < ApplicationRecord
  encrypts_decimal :quantity, :avg_cost

  belongs_to :portfolio
  belongs_to :asset

  before_validation :set_defaults
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :avg_cost, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true, length: { is: 3 }
  validates :asset_id, uniqueness: { scope: :portfolio_id }

  before_validation :normalize_currency

  private

  def set_defaults
    self.quantity = 0 if quantity.nil?
    self.avg_cost = 0 if avg_cost.nil?
  end

  def normalize_currency
    self.currency = currency.to_s.strip.upcase
  end
end
