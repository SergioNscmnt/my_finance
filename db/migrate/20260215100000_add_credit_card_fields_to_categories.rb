class AddCreditCardFieldsToCategories < ActiveRecord::Migration[7.1]
  def change
    add_column :categories, :credit_card, :boolean, default: false, null: false
    add_column :categories, :statement_closing_day, :integer
    add_column :categories, :statement_due_day, :integer
    add_column :categories, :reminder_days_before_due, :integer, default: 5, null: false
  end
end
