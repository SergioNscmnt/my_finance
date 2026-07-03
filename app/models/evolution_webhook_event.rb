class EvolutionWebhookEvent < ApplicationRecord
  serialize :payload, coder: JSON

  belongs_to :user, optional: true
  belongs_to :whatsapp_account, optional: true
  belongs_to :created_transaction, class_name: "Transaction", foreign_key: :transaction_id, optional: true

  enum status: {
    received: 0,
    processed: 1,
    pending: 2,
    ignored: 3,
    failed: 4
  }

  before_validation :normalize_sender_phone

  validates :event_name, presence: true
  validates :instance_name, presence: true
  validates :sender_phone, presence: true
  validates :message_id, presence: true
  validates :payload, presence: true
  validates :message_id, uniqueness: { scope: [:instance_name, :sender_phone] }

  def mark_processed!(transaction:)
    update!(status: :processed, created_transaction: transaction, processed_at: Time.current, error_message: nil)
  end

  def mark_pending!(message)
    update!(status: :pending, processed_at: Time.current, error_message: message)
  end

  def mark_ignored!(message = nil)
    update!(status: :ignored, processed_at: Time.current, error_message: message)
  end

  def mark_failed!(message)
    update!(status: :failed, processed_at: Time.current, error_message: message)
  end

  private

  def normalize_sender_phone
    self.sender_phone = WhatsappAccount.normalize_phone(sender_phone)
  end
end
