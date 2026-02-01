class CreateAllocationTargets < ActiveRecord::Migration[7.1]
  def change
    create_table :allocation_targets do |t|
      t.references :wallet, null: false, foreign_key: true
      t.integer :asset_class, null: false
      t.decimal :target_percentage, precision: 5, scale: 2, null: false
      t.timestamps
    end

    add_index :allocation_targets, [:wallet_id, :asset_class], unique: true
  end
end
