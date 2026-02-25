class AddMarketFieldsToAssets < ActiveRecord::Migration[7.1]
  def up
    add_column :assets, :asset_class, :integer, null: false, default: 0
    add_column :assets, :symbol, :string
    add_column :assets, :exchange, :string
    add_column :assets, :status, :integer, null: false, default: 0

    execute <<~SQL.squish
      UPDATE assets
      SET symbol = UPPER(TRIM(ticker))
      WHERE symbol IS NULL OR symbol = ''
    SQL

    change_column_null :assets, :symbol, false

    add_index :assets, %i[symbol exchange], unique: true
    add_index :assets, :asset_class
    add_index :assets, :status
  end

  def down
    remove_index :assets, :status
    remove_index :assets, :asset_class
    remove_index :assets, column: %i[symbol exchange]

    remove_column :assets, :status
    remove_column :assets, :exchange
    remove_column :assets, :symbol
    remove_column :assets, :asset_class
  end
end
