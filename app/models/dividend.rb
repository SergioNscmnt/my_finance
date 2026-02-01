class Dividend < ApplicationRecord
  belongs_to :wallet
  belongs_to :asset

  enum kind: { dividend: 0, interest: 1, coupon: 2 }

  validates :amount, numericality: { greater_than: 0 }
  validates :paid_on, presence: true
  validates :kind, presence: true
end
