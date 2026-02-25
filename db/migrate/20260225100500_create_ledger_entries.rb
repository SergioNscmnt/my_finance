class CreateLedgerEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :ledger_entries do |t|
      t.references :portfolio, null: false, foreign_key: true
      t.integer :entry_type, null: false
      t.string :currency, null: false
      t.decimal :amount, precision: 20, scale: 8, null: false
      t.json :metadata
      t.datetime :occurred_at, null: false

      t.timestamps
    end

    add_index :ledger_entries, %i[portfolio_id occurred_at]
    add_index :ledger_entries, %i[portfolio_id entry_type occurred_at], name: "index_ledger_entries_on_portfolio_type_date"
  end
end
