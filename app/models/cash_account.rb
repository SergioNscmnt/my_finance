class CashAccount < ApplicationRecord
  belongs_to :portfolio

  validates :currency, presence: true, length: { is: 3 }
  validates :balance, numericality: true
  validates :currency, uniqueness: { scope: :portfolio_id }

  before_validation :normalize_currency

  private

  def normalize_currency
    self.currency = currency.to_s.strip.upcase
  end
end
