class AddBudgetMonthToCategoryBudgets < ActiveRecord::Migration[7.1]
  def up
    add_column :category_budgets, :budget_month, :date

    current_month = Date.current.beginning_of_month
    execute <<~SQL.squish
      UPDATE category_budgets
      SET budget_month = '#{current_month}'
      WHERE budget_month IS NULL
    SQL

    change_column_null :category_budgets, :budget_month, false
    remove_index :category_budgets, [:user_id, :category_id]
    add_index :category_budgets,
              [:user_id, :category_id, :budget_month],
              unique: true,
              name: "index_category_budgets_on_user_category_month"
  end

  def down
    remove_index :category_budgets, name: "index_category_budgets_on_user_category_month"
    add_index :category_budgets, [:user_id, :category_id], unique: true
    remove_column :category_budgets, :budget_month
  end
end
