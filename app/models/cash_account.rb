class CashAccount < ApplicationRecord
  encrypts_decimal :balance

  belongs_to :portfolio

  validates :currency, presence: true, length: { is: 3 }
  validates :balance, numericality: true
  validates :currency, uniqueness: { scope: :portfolio_id }

  before_validation :set_defaults
  before_validation :normalize_currency

  private

  def set_defaults
    self.balance = 0 if balance.nil?
  end

  def normalize_currency
    self.currency = currency.to_s.strip.upcase
  end
end
