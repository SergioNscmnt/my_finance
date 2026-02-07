class CreateMarketInstruments < ActiveRecord::Migration[7.1]
  def change
    create_table :market_instruments do |t|
      t.string :ticker, null: false
      t.string :name, null: false
      t.integer :asset_type, null: false
      t.string :market
      t.string :locale
      t.string :currency, default: "USD", null: false
      t.boolean :active, default: true, null: false
      t.datetime :last_synced_at

      t.timestamps
    end

    add_index :market_instruments, :ticker, unique: true
    add_index :market_instruments, :asset_type
    add_index :market_instruments, :active
  end
end
