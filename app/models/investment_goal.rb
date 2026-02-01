class InvestmentGoal < ApplicationRecord
  belongs_to :wallet

  enum goal_type: { retirement: 0, reserve: 1, freedom: 2, custom: 3 }

  validates :name, presence: true
  validates :target_amount, numericality: { greater_than: 0 }
  validates :target_date, presence: true
end
