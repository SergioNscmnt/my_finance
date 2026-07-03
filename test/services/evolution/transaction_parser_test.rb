require "test_helper"

class Evolution::TransactionParserTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @alimentacao = @user.categories.create!(name: "Alimentação", kind: :expense)
    @salario = @user.categories.create!(name: "Salário", kind: :income)
  end

  test "parses expense with currency and credit card" do
    result = Evolution::TransactionParser.new(
      user: @user,
      text: "Bom dia, gastei R$ 30,00 no café da manhã no cartão de crédito.",
      occurred_on: Date.new(2026, 7, 3)
    ).call

    assert result.valid?
    assert_equal BigDecimal("30.00"), result.amount
    assert_equal "expense", result.kind
    assert_equal @alimentacao, result.category
    assert_equal "credit_card", result.payment_method
    assert_equal Date.new(2026, 7, 3), result.occurred_on
  end

  test "parses income salary as pix" do
    result = Evolution::TransactionParser.new(
      user: @user,
      text: "Bom dia, recebi o salário no valor de 5800,00."
    ).call

    assert result.valid?
    assert_equal BigDecimal("5800.00"), result.amount
    assert_equal "income", result.kind
    assert_equal @salario, result.category
    assert_equal "pix", result.payment_method
  end

  test "maps ted to pix" do
    result = Evolution::TransactionParser.new(
      user: @user,
      text: "Recebi salário de 5.800,00 por TED"
    ).call

    assert result.valid?
    assert_equal "pix", result.payment_method
  end

  test "reports missing fields" do
    result = Evolution::TransactionParser.new(user: @user, text: "Bom dia").call

    assert_not result.valid?
    assert_includes result.errors, "valor não identificado"
    assert_includes result.errors, "tipo da transação não identificado"
    assert_includes result.errors, "categoria não identificada"
  end
end
