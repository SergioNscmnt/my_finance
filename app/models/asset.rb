class Asset < ApplicationRecord
  belongs_to :wallet
  has_many :investment_transactions, dependent: :destroy
  has_many :dividends, dependent: :destroy

  enum asset_type: { stock: 0, fii: 1, fixed_income: 2, crypto: 3, fund: 4 }

  validates :name, presence: true
  validates :ticker, presence: true
  validates :asset_type, presence: true
  validates :currency, presence: true

  validates :ticker, uniqueness: { scope: :wallet_id, case_sensitive: false }
end
