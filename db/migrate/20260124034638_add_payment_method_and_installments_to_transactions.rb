class AddPaymentMethodAndInstallmentsToTransactions < ActiveRecord::Migration[7.1]
  def change
    add_column :transactions, :payment_method, :integer, default: 0, null: false
    add_column :transactions, :installments, :integer, default: 1, null: false
  end
end
