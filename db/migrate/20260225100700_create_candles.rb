class CreateCandles < ActiveRecord::Migration[7.1]
  def change
    create_table :candles do |t|
      t.references :asset, null: false, foreign_key: true
      t.string :timeframe, null: false
      t.datetime :timestamp, null: false
      t.decimal :open, precision: 20, scale: 8, null: false
      t.decimal :high, precision: 20, scale: 8, null: false
      t.decimal :low, precision: 20, scale: 8, null: false
      t.decimal :close, precision: 20, scale: 8, null: false
      t.decimal :volume, precision: 24, scale: 8

      t.timestamps
    end

    add_index :candles, %i[asset_id timeframe timestamp], unique: true, name: "index_candles_on_asset_timeframe_timestamp"
    add_index :candles, %i[asset_id timeframe]
  end
end
