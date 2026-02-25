class CreateQuotes < ActiveRecord::Migration[7.1]
  def change
    create_table :quotes do |t|
      t.references :asset, null: false, foreign_key: true
      t.decimal :price, precision: 20, scale: 8, null: false
      t.decimal :change_percent, precision: 12, scale: 6
      t.string :provider, null: false
      t.datetime :provider_timestamp, null: false
      t.datetime :retrieved_at, null: false

      t.timestamps
    end

    add_index :quotes, %i[asset_id retrieved_at]
    add_index :quotes, %i[asset_id provider_timestamp]
  end
end
