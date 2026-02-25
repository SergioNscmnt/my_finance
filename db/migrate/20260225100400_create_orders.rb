class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :portfolio, null: false, foreign_key: true
      t.references :asset, null: false, foreign_key: true
      t.integer :side, null: false
      t.decimal :quantity, precision: 24, scale: 10, null: false
      t.integer :status, null: false, default: 0
      t.decimal :filled_price, precision: 20, scale: 8
      t.decimal :fees, precision: 20, scale: 8, null: false, default: 0
      t.string :provider
      t.datetime :provider_quote_timestamp
      t.datetime :requested_at, null: false
      t.datetime :filled_at

      t.timestamps
    end

    add_index :orders, %i[portfolio_id status requested_at]
    add_index :orders, %i[asset_id requested_at]
  end
end
