class AdjustCategoryUniquenessForCreditCardBank < ActiveRecord::Migration[7.1]
  def change
    remove_index :categories, name: "index_categories_on_user_id_and_name", if_exists: true
    add_index :categories, [:user_id, :name], name: "index_categories_on_user_id_and_name"

    add_index :categories, [:user_id, :card_bank], unique: true, name: "index_categories_on_user_id_and_card_bank"
  end
end
