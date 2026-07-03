class CreateWhatsappAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :whatsapp_accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :phone_number, null: false
      t.string :instance_name, null: false
      t.boolean :enabled, null: false, default: true
      t.datetime :last_seen_at

      t.timestamps
    end

    add_index :whatsapp_accounts, [:instance_name, :phone_number], unique: true
    add_index :whatsapp_accounts, :enabled
  end
end
