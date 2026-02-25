class CreateFxRates < ActiveRecord::Migration[7.1]
  def change
    create_table :fx_rates do |t|
      t.string :base_currency, null: false
      t.string :quote_currency, null: false
      t.decimal :rate, precision: 20, scale: 10, null: false
      t.date :rate_date, null: false
      t.string :provider, null: false, default: "frankfurter"
      t.datetime :retrieved_at, null: false

      t.timestamps
    end

    add_index :fx_rates, %i[base_currency quote_currency rate_date], unique: true, name: "index_fx_rates_on_pair_and_rate_date"
    add_index :fx_rates, %i[base_currency quote_currency retrieved_at], name: "index_fx_rates_on_pair_and_retrieved_at"
  end
end
