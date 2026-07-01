require "test_helper"

class CategoryBudgetTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Budget Teste", email: "budget@example.com", password: "password")
    @category = @user.categories.expense.first
  end

  test "allows one budget per category in each month" do
    june_budget = @user.category_budgets.create!(
      category: @category,
      amount: 500,
      budget_month: Date.new(2026, 6, 15)
    )

    july_budget = @user.category_budgets.create!(
      category: @category,
      amount: 700,
      budget_month: Date.new(2026, 7, 20)
    )

    assert_equal Date.new(2026, 6, 1), june_budget.budget_month
    assert_equal Date.new(2026, 7, 1), july_budget.budget_month
  end

  test "prevents duplicate category budget in the same month" do
    @user.category_budgets.create!(
      category: @category,
      amount: 500,
      budget_month: Date.new(2026, 6, 1)
    )

    duplicate = @user.category_budgets.new(
      category: @category,
      amount: 700,
      budget_month: Date.new(2026, 6, 30)
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:category_id], "já está em uso"
  end
end
