class CreateDividends < ActiveRecord::Migration[7.1]
  def change
    create_table :dividends do |t|
      t.references :wallet, null: false, foreign_key: true
      t.references :asset, null: false, foreign_key: true
      t.integer :kind, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.date :paid_on, null: false
      t.boolean :reinvested, null: false, default: false
      t.timestamps
    end

    add_index :dividends, [:wallet_id, :paid_on]
  end
end
