class CategoryBudget < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :category_id, uniqueness: { scope: :user_id }
  validate :category_must_belong_to_user
  validate :category_must_be_expense

  private

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
