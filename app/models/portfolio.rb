class Portfolio < ApplicationRecord
  belongs_to :user

  has_many :cash_accounts, dependent: :destroy
  has_many :positions, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :ledger_entries, dependent: :destroy

  validates :base_currency, presence: true, length: { is: 3 }

  before_validation :normalize_base_currency

  private

  def normalize_base_currency
    self.base_currency = base_currency.to_s.strip.upcase
  end
end
