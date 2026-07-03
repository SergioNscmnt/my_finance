require "test_helper"

class EncryptedFinancialAttributesTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Cripto Teste", email: "cripto@example.com", password: "password")
    @income_category = @user.categories.income.first
    @expense_category = @user.categories.expense.first
  end

  test "encrypts transaction amount at rest" do
    transaction = @user.transactions.create!(
      title: "Receita sensível",
      amount: 1234.56,
      kind: :income,
      occurred_on: Date.new(2026, 7, 1),
      category: @income_category
    )

    assert_equal BigDecimal("1234.56"), transaction.reload.amount
    assert_encrypted_at_rest Transaction, transaction.id, :amount, plaintext: "1234.56"
  end

  test "encrypts category budget amount at rest" do
    budget = @user.category_budgets.create!(
      category: @expense_category,
      amount: 789.10,
      budget_month: Date.new(2026, 7, 1)
    )

    assert_equal BigDecimal("789.1"), budget.reload.amount
    assert_encrypted_at_rest CategoryBudget, budget.id, :amount, plaintext: "789.1"
  end

  test "encrypts cash account balance at rest" do
    portfolio = Portfolio.create!(user: @user, base_currency: "BRL")
    cash_account = portfolio.cash_accounts.create!(currency: "BRL", balance: 2500.75)

    assert_equal BigDecimal("2500.75"), cash_account.reload.balance
    assert_encrypted_at_rest CashAccount, cash_account.id, :balance, plaintext: "2500.75"
  end

  private

  def assert_encrypted_at_rest(model, id, column, plaintext:)
    raw_value = model.connection.select_value(
      "SELECT #{model.connection.quote_column_name(column)} FROM #{model.connection.quote_table_name(model.table_name)} WHERE id = #{id.to_i}"
    )

    assert raw_value.present?
    assert_match(/"p":|"p"\s*:/, raw_value)
    refute_equal plaintext, raw_value
    refute_includes raw_value, plaintext
  end
end
