class CreateWallets < ActiveRecord::Migration[7.1]
  def change
    create_table :wallets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :currency, null: false, default: "BRL"
      t.timestamps
    end
  end
end
