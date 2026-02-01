class Wallet < ApplicationRecord
  belongs_to :user
  has_many :assets, dependent: :destroy
  has_many :investment_transactions, dependent: :destroy
  has_many :dividends, dependent: :destroy
  has_many :investment_goals, dependent: :destroy
  has_many :allocation_targets, dependent: :destroy

  validates :name, presence: true
  validates :currency, presence: true
end
