class Transaction < ApplicationRecord
  belongs_to :category
  belongs_to :user

  enum kind: { income: 0, expense: 1 }
  enum payment_method: { cash: 0, credit_card: 1, pix: 2 }

  after_initialize :set_defaults, if: :new_record?

  validates :title, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :kind, presence: true
  validates :occurred_on, presence: true
  validates :installments, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  def per_installment_amount
    return amount if !credit_card? || installments.to_i <= 1
    (amount / installments).round(2)
  end

  # Retorna o valor que impacta o mês informado.
  def monthly_amount_for(date)
    month = date.to_date.beginning_of_month
    start_month = occurred_on.beginning_of_month

    if credit_card? && installments.to_i > 1
      end_month = start_month + (installments - 1).months
      return 0 if month < start_month || month > end_month
      per_installment_amount
    else
      month == start_month ? amount : 0
    end
  end

  def monthly_impact(date)
    value = monthly_amount_for(date)
    income? ? value : -value
  end

  def display_amount
    credit_card? && installments.to_i > 1 ? per_installment_amount : amount
  end

  def installment_number_for(date = Date.current)
    return nil unless credit_card? && installments.to_i > 1
    month = date.to_date.beginning_of_month
    start_month = occurred_on.beginning_of_month
    end_month = start_month + (installments - 1).months
    return nil if month < start_month || month > end_month
    (month.year * 12 + month.month) - (start_month.year * 12 + start_month.month) + 1
  end

  private

  def set_defaults
    self.payment_method ||= "cash"
    self.installments ||= 1
  end
end
