class AllocationTarget < ApplicationRecord
  belongs_to :wallet

  enum asset_class: { stock: 0, fii: 1, fixed_income: 2, crypto: 3, fund: 4 }

  validates :asset_class, presence: true
  validates :target_percentage, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :asset_class, uniqueness: { scope: :wallet_id }
end
