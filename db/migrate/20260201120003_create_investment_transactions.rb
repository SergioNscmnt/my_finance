class CreateInvestmentTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :investment_transactions do |t|
      t.references :wallet, null: false, foreign_key: true
      t.references :asset, null: false, foreign_key: true
      t.integer :kind, null: false
      t.decimal :quantity, precision: 15, scale: 6, null: false
      t.decimal :price, precision: 15, scale: 6, null: false
      t.decimal :fees, precision: 12, scale: 2, null: false, default: 0
      t.date :occurred_on, null: false
      t.timestamps
    end

    add_index :investment_transactions, [:wallet_id, :occurred_on]
    add_index :investment_transactions, [:asset_id, :occurred_on]
  end
end
