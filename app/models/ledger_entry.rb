class LedgerEntry < ApplicationRecord
  belongs_to :portfolio

  enum entry_type: {
    cash_in: 0,
    cash_out: 1,
    buy_fill: 2,
    sell_fill: 3,
    fee: 4,
    dividend: 5,
    adjustment: 6
  }

  validates :entry_type, presence: true
  validates :currency, presence: true, length: { is: 3 }
  validates :amount, numericality: true
  validates :occurred_at, presence: true

  before_validation :normalize_currency

  private

  def normalize_currency
    self.currency = currency.to_s.strip.upcase
  end
end
