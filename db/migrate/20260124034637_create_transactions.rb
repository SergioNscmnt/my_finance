class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.string :title, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.integer :kind, null: false
      t.date :occurred_on, null: false
      t.references :category, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :transactions, [:user_id, :occurred_on]
    add_index :transactions, :kind
  end
end
