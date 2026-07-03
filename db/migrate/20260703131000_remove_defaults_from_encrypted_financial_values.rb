class RemoveDefaultsFromEncryptedFinancialValues < ActiveRecord::Migration[7.1]
  ENCRYPTED_DEFAULTS = {
    cash_accounts: { balance: 0 },
    credit_card_invoices: { total_amount: 0 },
    investment_goals: { monthly_contribution: 0 },
    investment_transactions: { fees: 0 },
    orders: { fees: 0 },
    positions: { quantity: 0, avg_cost: 0 }
  }.freeze

  def up
    ENCRYPTED_DEFAULTS.each do |table, columns|
      columns.each_key do |column|
        change_column_default table, column, nil
      end
    end
  end

  def down
    ENCRYPTED_DEFAULTS.each do |table, columns|
      columns.each do |column, default|
        change_column_default table, column, default
      end
    end
  end
end
