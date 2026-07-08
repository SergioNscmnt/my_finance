class CategoryBudget < ApplicationRecord
  encrypts_decimal :amount

  belongs_to :user
  belongs_to :category

  before_validation :normalize_budget_month

  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :budget_month, presence: true
  validates :category_id, uniqueness: { scope: %i[user_id budget_month] }
  validate :category_must_belong_to_user
  validate :category_must_be_expense

  private

  def normalize_budget_month
    value = budget_month.presence || Date.current
    self.budget_month = if value.is_a?(String) && value.match?(/\A\d{4}-\d{2}\z/)
      Date.strptime(value, "%Y-%m")
    else
      value.to_date.beginning_of_month
    end
  end

  def category_must_belong_to_user
    return if category.blank? || user.blank?
    return if category.user_id == user_id

    errors.add(:category, "deve pertencer ao usuário")
  end

  def category_must_be_expense
    return if category.blank?
    return if category.expense?

    errors.add(:category, "deve ser uma categoria de despesa")
  end
end
