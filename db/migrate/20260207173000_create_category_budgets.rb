class CreateCategoryBudgets < ActiveRecord::Migration[7.1]
  def change
    create_table :category_budgets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.decimal :amount, precision: 12, scale: 2, null: false

      t.timestamps
    end

    add_index :category_budgets, [:user_id, :category_id], unique: true
  end
end
