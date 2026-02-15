class Category < ApplicationRecord
  CARD_BANK_OPTIONS = [
    "Nubank",
    "Itaú",
    "Bradesco",
    "Santander",
    "Banco do Brasil",
    "Caixa Econômica Federal",
    "Banco Inter",
    "C6 Bank",
    "BTG Pactual",
    "Sicredi",
    "Sicoob"
  ].freeze

  belongs_to :user
  has_many :transactions, dependent: :restrict_with_exception
  has_many :category_budgets, dependent: :destroy
  has_many :credit_card_invoices, dependent: :destroy

  enum kind: { income: 0, expense: 1 }

  before_validation :normalize_credit_card_fields

  validates :name, presence: true
  validates :kind, presence: true
  validate :name_uniqueness_for_non_credit_categories
  validates :statement_closing_day, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 31 }, if: :credit_card?
  validates :statement_due_day, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 31 }, if: :credit_card?
  validates :card_bank,
            presence: true,
            inclusion: { in: CARD_BANK_OPTIONS },
            uniqueness: { scope: :user_id, case_sensitive: false, message: "já está em uso em outra categoria de cartão" },
            if: :credit_card?
  validates :reminder_days_before_due, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 30 }
  validate :credit_card_requires_expense_kind

  def billing_month_for(date)
    base_month = date.to_date.beginning_of_month
    return base_month unless credit_card?

    date.day > statement_closing_day.to_i ? base_month.next_month : base_month
  end

  def due_date_for_billing_month(billing_month)
    month = billing_month.to_date.beginning_of_month
    due_month = statement_due_day.to_i <= statement_closing_day.to_i ? month.next_month : month
    day = [statement_due_day.to_i, due_month.end_of_month.day].min
    Date.new(due_month.year, due_month.month, day)
  end

  private

  def normalize_credit_card_fields
    return if credit_card?

    self.statement_closing_day = nil
    self.statement_due_day = nil
    self.card_bank = nil
    self.reminder_days_before_due = 5 if reminder_days_before_due.blank?
  end

  def credit_card_requires_expense_kind
    return unless credit_card?
    return if expense?

    errors.add(:kind, "deve ser despesa para categoria de cartão de crédito")
  end

  def name_uniqueness_for_non_credit_categories
    return if credit_card?
    return if name.blank?

    scope = self.class.where(user_id: user_id, credit_card: false).where("LOWER(name) = ?", name.downcase)
    scope = scope.where.not(id: id) if persisted?
    return unless scope.exists?

    errors.add(:name, "já está em uso")
  end
end
