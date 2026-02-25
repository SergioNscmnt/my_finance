class FxRate < ApplicationRecord
  validates :base_currency, :quote_currency, :provider, :rate_date, :retrieved_at, presence: true
  validates :base_currency, :quote_currency, length: { is: 3 }
  validates :rate, numericality: { greater_than: 0 }

  scope :for_pair, ->(base, quote) { where(base_currency: base.to_s.upcase, quote_currency: quote.to_s.upcase) }
  scope :latest_first, -> { order(rate_date: :desc, retrieved_at: :desc, id: :desc) }

  before_validation :normalize_fields

  private

  def normalize_fields
    self.base_currency = base_currency.to_s.strip.upcase
    self.quote_currency = quote_currency.to_s.strip.upcase
    self.provider = provider.to_s.strip.downcase
  end
end
