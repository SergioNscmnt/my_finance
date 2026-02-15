class User < ApplicationRecord
  has_secure_password

  has_many :categories, dependent: :destroy
  has_many :category_budgets, dependent: :destroy
  has_many :credit_card_invoices, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :wallets, dependent: :destroy
  has_many :assets, through: :wallets
  has_many :investment_transactions, through: :wallets
  has_many :dividends, through: :wallets

  after_create :ensure_default_categories

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  private

  def ensure_default_categories
    defaults = {
      income: ["Salário", "Bônus", "Freelance", "Reembolso", "Investimentos (receita)", "Outras receitas"],
      expense: ["Alimentação", "Transporte", "Moradia", "Saúde", "Lazer", "Educação", "Contas e Serviços", "Compras", "Animais de Estimação", "Investimentos (despesa)", "Outras despesas"]
    }
    defaults.each do |kind, names|
      names.each do |name|
        categories.find_or_create_by!(kind: kind, name: name)
      end
    end
  end
end
