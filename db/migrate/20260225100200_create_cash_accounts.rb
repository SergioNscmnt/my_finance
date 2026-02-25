class CreateCashAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :cash_accounts do |t|
      t.references :portfolio, null: false, foreign_key: true
      t.string :currency, null: false
      t.decimal :balance, precision: 20, scale: 8, null: false, default: 0

      t.timestamps
    end

    add_index :cash_accounts, %i[portfolio_id currency], unique: true
  end
end
