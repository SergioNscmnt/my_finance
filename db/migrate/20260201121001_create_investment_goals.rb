class CreateInvestmentGoals < ActiveRecord::Migration[7.1]
  def change
    create_table :investment_goals do |t|
      t.references :wallet, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :goal_type, null: false, default: 3
      t.decimal :target_amount, precision: 15, scale: 2, null: false
      t.date :target_date, null: false
      t.decimal :monthly_contribution, precision: 12, scale: 2, null: false, default: 0
      t.timestamps
    end
  end
end
