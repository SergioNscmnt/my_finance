class CreateEvolutionWebhookEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :evolution_webhook_events do |t|
      t.references :user, null: true, foreign_key: true
      t.references :whatsapp_account, null: true, foreign_key: true
      t.references :transaction, null: true, foreign_key: true
      t.string :event_name, null: false
      t.string :instance_name, null: false
      t.string :sender_phone, null: false
      t.string :message_id, null: false
      t.string :message_type
      t.text :message_text
      t.boolean :from_me, null: false, default: false
      t.json :payload, null: false
      t.integer :status, null: false, default: 0
      t.text :error_message
      t.datetime :processed_at

      t.timestamps
    end

    add_index :evolution_webhook_events,
              [:instance_name, :sender_phone, :message_id],
              unique: true,
              name: "index_evolution_events_on_instance_sender_message"
    add_index :evolution_webhook_events, :event_name
    add_index :evolution_webhook_events, :status
  end
end
