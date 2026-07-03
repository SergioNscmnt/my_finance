class AddPaymentMethodAndInstallmentsToTransactions < ActiveRecord::Migration[7.1]
  def up
    unless column_exists?(:transactions, :payment_method)
      add_column :transactions, :payment_method, :integer, default: 0, null: false
    end

    unless column_exists?(:transactions, :installments)
      add_column :transactions, :installments, :integer, default: 1, null: false
    end
  end

  def down
    remove_column :transactions, :installments if column_exists?(:transactions, :installments)
    remove_column :transactions, :payment_method if column_exists?(:transactions, :payment_method)
  end
end
