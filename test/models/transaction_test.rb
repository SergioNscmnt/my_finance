require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Saldo Teste", email: "saldo@example.com", password: "password")
    @income_category = @user.categories.income.first
    @expense_category = @user.categories.expense.first
  end

  test "cumulative balance carries surplus to following month" do
    transactions = [
      @user.transactions.create!(
        title: "Receita junho",
        amount: 1_000,
        kind: :income,
        occurred_on: Date.new(2026, 6, 10),
        category: @income_category
      ),
      @user.transactions.create!(
        title: "Despesa junho",
        amount: 700,
        kind: :expense,
        occurred_on: Date.new(2026, 6, 20),
        category: @expense_category
      ),
      @user.transactions.create!(
        title: "Despesa julho",
        amount: 500,
        kind: :expense,
        occurred_on: Date.new(2026, 7, 5),
        category: @expense_category
      )
    ]

    assert_equal 300, Transaction.cumulative_balance_for(transactions, Date.new(2026, 6, 30))
    assert_equal(-200, Transaction.cumulative_balance_for(transactions, Date.new(2026, 7, 31)))
  end

  test "cumulative balance carries installment impact month by month" do
    transaction = @user.transactions.create!(
      title: "Compra parcelada",
      amount: 300,
      kind: :expense,
      occurred_on: Date.new(2026, 6, 15),
      category: @expense_category,
      payment_method: :credit_card,
      installments: 3
    )

    assert_equal(-100, Transaction.cumulative_balance_for([transaction], Date.new(2026, 6, 30)))
    assert_equal(-200, Transaction.cumulative_balance_for([transaction], Date.new(2026, 7, 31)))
    assert_equal(-300, Transaction.cumulative_balance_for([transaction], Date.new(2026, 8, 31)))
  end
end
