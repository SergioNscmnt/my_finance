class Quote < ApplicationRecord
  belongs_to :asset

  validates :price, numericality: { greater_than: 0 }
  validates :change_percent, numericality: true, allow_nil: true
  validates :provider, presence: true
  validates :provider_timestamp, presence: true
  validates :retrieved_at, presence: true

  scope :latest_first, -> { order(retrieved_at: :desc, id: :desc) }

  before_validation :normalize_provider

  private

  def normalize_provider
    self.provider = provider.to_s.strip.downcase
  end
end
