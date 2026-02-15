class CreditCardInvoice < ApplicationRecord
  belongs_to :user
  belongs_to :category

  enum status: { open: 0, paid: 1, overdue: 2 }

  validates :billing_month, presence: true
  validates :due_on, presence: true
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :category_id, uniqueness: { scope: :billing_month }
end
