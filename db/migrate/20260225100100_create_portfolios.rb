class CreatePortfolios < ActiveRecord::Migration[7.1]
  def change
    create_table :portfolios do |t|
      t.references :user, null: false, foreign_key: true
      t.string :base_currency, null: false, default: "BRL"

      t.timestamps
    end

    add_index :portfolios, :base_currency
  end
end
