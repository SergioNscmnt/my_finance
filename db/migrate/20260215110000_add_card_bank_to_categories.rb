class AddCardBankToCategories < ActiveRecord::Migration[7.1]
  def change
    add_column :categories, :card_bank, :string
  end
end
