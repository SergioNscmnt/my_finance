class Asset < ApplicationRecord
  ASSET_TYPE_LABELS_PT_BR = {
    "stock" => "Ações",
    "fii" => "FIIs",
    "fixed_income" => "Renda fixa",
    "crypto" => "Criptoativos",
    "fund" => "Fundos"
  }.freeze

  belongs_to :wallet
  has_many :investment_transactions, dependent: :destroy
  has_many :dividends, dependent: :destroy
  has_many :positions, dependent: :restrict_with_error
  has_many :orders, dependent: :restrict_with_error
  has_many :quotes, dependent: :destroy
  has_many :candles, dependent: :destroy

  enum asset_type: { stock: 0, fii: 1, fixed_income: 2, crypto: 3, fund: 4 }
  enum asset_class: { stock: 0, etf: 1, index: 2, cash: 3 }, _prefix: :asset_class
  enum status: { active: 0, inactive: 1 }

  before_validation :normalize_fields

  validates :name, presence: true
  validates :ticker, presence: true
  validates :symbol, presence: true
  validates :asset_type, presence: true
  validates :asset_class, presence: true
  validates :status, presence: true
  validates :currency, presence: true
  validates :symbol, uniqueness: { scope: :exchange, case_sensitive: false }

  validates :ticker,
            uniqueness: {
              scope: :wallet_id,
              case_sensitive: false,
              message: "já está cadastrado na sua carteira"
            }

  def self.asset_type_options_pt_br
    asset_types.keys.map { |key| [ASSET_TYPE_LABELS_PT_BR.fetch(key, key.humanize), key] }
  end

  def asset_type_label_pt_br
    ASSET_TYPE_LABELS_PT_BR.fetch(asset_type, asset_type.to_s.humanize)
  end

  private

  def normalize_fields
    self.ticker = ticker.to_s.strip.upcase if ticker.present?
    self.symbol = (symbol.presence || ticker).to_s.strip.upcase if symbol.present? || ticker.present?
    self.exchange = exchange.to_s.strip.upcase if exchange.present?
    self.currency = currency.to_s.strip.upcase if currency.present?
    self.asset_type = inferred_asset_type if asset_type.blank?
    self.asset_class = inferred_asset_class if asset_class.blank?
  end

  def inferred_asset_type
    return nil if ticker.blank?
    ticker.to_s.upcase.end_with?("11") ? "fii" : "stock"
  end

  def inferred_asset_class
    return "stock" if asset_type.blank?
    %w[stock fii fund].include?(asset_type.to_s) ? "stock" : "cash"
  end
end
