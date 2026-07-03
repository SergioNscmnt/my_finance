class CreditCardInvoice < ApplicationRecord
  encrypts_decimal :total_amount

  belongs_to :user
  belongs_to :category

  enum status: { open: 0, paid: 1, overdue: 2 }

  before_validation :set_defaults

  validates :billing_month, presence: true
  validates :due_on, presence: true
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :category_id, uniqueness: { scope: :billing_month }

  private

  def set_defaults
    self.total_amount = 0 if total_amount.nil?
  end
end
