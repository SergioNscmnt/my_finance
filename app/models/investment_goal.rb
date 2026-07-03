class InvestmentGoal < ApplicationRecord
  encrypts_decimal :target_amount, :monthly_contribution

  belongs_to :wallet

  enum goal_type: { retirement: 0, reserve: 1, freedom: 2, custom: 3 }

  before_validation :set_defaults

  validates :name, presence: true
  validates :target_amount, numericality: { greater_than: 0 }
  validates :target_date, presence: true

  private

  def set_defaults
    self.monthly_contribution = 0 if monthly_contribution.nil?
  end
end
