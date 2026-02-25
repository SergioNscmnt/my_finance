class CreatePositions < ActiveRecord::Migration[7.1]
  def change
    create_table :positions do |t|
      t.references :portfolio, null: false, foreign_key: true
      t.references :asset, null: false, foreign_key: true
      t.decimal :quantity, precision: 24, scale: 10, null: false, default: 0
      t.decimal :avg_cost, precision: 20, scale: 8, null: false, default: 0
      t.string :currency, null: false

      t.timestamps
    end

    add_index :positions, %i[portfolio_id asset_id], unique: true
    add_index :positions, %i[portfolio_id currency]
  end
end
