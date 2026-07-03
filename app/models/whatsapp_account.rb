class WhatsappAccount < ApplicationRecord
  belongs_to :user
  has_many :evolution_webhook_events, dependent: :nullify

  before_validation :normalize_phone_number

  validates :phone_number, presence: true
  validates :instance_name, presence: true
  validates :phone_number, uniqueness: { scope: :instance_name }

  scope :enabled, -> { where(enabled: true) }

  def self.normalize_phone(value)
    value.to_s.gsub(/\D/, "")
  end

  private

  def normalize_phone_number
    self.phone_number = self.class.normalize_phone(phone_number)
  end
end
