class InvestmentTransaction < ApplicationRecord
  encrypts_decimal :quantity, :price, :fees

  belongs_to :wallet
  belongs_to :asset

  enum kind: { buy: 0, sell: 1 }

  before_validation :set_defaults

  validates :kind, presence: true
  validates :occurred_on, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :fees, numericality: { greater_than_or_equal_to: 0 }

  validate :buy_or_sell_requires_price

  scope :ordered, -> { order(occurred_on: :asc, id: :asc) }

  private

  def set_defaults
    self.fees = 0 if fees.nil?
  end

  def buy_or_sell_requires_price
    return unless (buy? || sell?) && price.to_d <= 0
    errors.add(:price, "must be greater than 0 for buy/sell")
  end
end
