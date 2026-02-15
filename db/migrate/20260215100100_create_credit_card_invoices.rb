class CreateCreditCardInvoices < ActiveRecord::Migration[7.1]
  def change
    create_table :credit_card_invoices do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.date :billing_month, null: false
      t.date :due_on, null: false
      t.decimal :total_amount, precision: 12, scale: 2, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.datetime :paid_at

      t.timestamps
    end

    add_index :credit_card_invoices, [:category_id, :billing_month], unique: true
    add_index :credit_card_invoices, [:user_id, :status]
    add_index :credit_card_invoices, [:user_id, :due_on]
  end
end
