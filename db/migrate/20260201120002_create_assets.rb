class CreateAssets < ActiveRecord::Migration[7.1]
  def change
    create_table :assets do |t|
      t.references :wallet, null: false, foreign_key: true
      t.string :name, null: false
      t.string :ticker, null: false
      t.integer :asset_type, null: false
      t.string :currency, null: false, default: "BRL"
      t.timestamps
    end

    add_index :assets, [:wallet_id, :ticker], unique: true
  end
end
