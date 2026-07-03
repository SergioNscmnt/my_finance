class Order < ApplicationRecord
  encrypts_decimal :quantity, :filled_price, :fees

  belongs_to :portfolio
  belongs_to :asset

  enum side: { buy: 0, sell: 1 }
  enum status: { pending: 0, filled: 1, rejected: 2, canceled: 3 }

  validates :side, presence: true
  validates :status, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :filled_price, numericality: { greater_than: 0 }, allow_nil: true
  validates :fees, numericality: { greater_than_or_equal_to: 0 }
  validates :requested_at, presence: true

  before_validation :set_defaults
  before_validation :normalize_provider

  private

  def set_defaults
    self.fees = 0 if fees.nil?
  end

  def normalize_provider
    self.provider = provider.to_s.strip.downcase.presence
  end
end
