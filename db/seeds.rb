seed_email = ENV.fetch("SEED_USER_EMAIL", "demo@example.com")
seed_password = ENV.fetch("SEED_USER_PASSWORD", "password123")

user = User.find_or_create_by!(email: seed_email) do |u|
  u.name = ENV.fetch("SEED_USER_NAME", "Demo User")
  u.password = seed_password
  u.password_confirmation = seed_password
end

default_categories = {
  income: [
    "Salário",
    "Bônus",
    "Freelance",
    "Reembolso",
    "Investimentos (receita)",
    "Outras receitas"
  ],
  expense: [
    "Alimentação",
    "Transporte",
    "Moradia",
    "Saúde",
    "Lazer",
    "Educação",
    "Contas e Serviços",
    "Compras",
    "Investimentos (despesa)",
    "Outras despesas"
  ]
}

default_categories.each do |kind, names|
  names.each do |name|
    Category.find_or_create_by!(name: name, kind: kind, user: user)
  end
end

def seed_installments!(user, category_name:, start_date:, max_installments:)
  category = Category.find_by!(user: user, kind: :expense, name: category_name)

  1.upto(max_installments) do |installments|
    total_amount = 1000 + (installments * 50)
    per_installment = (total_amount.to_f / installments).round(2)
    title_base = "Compra cartão #{installments}x"

    1.upto(installments) do |i|
      occurred_on = start_date.next_month(i - 1)
      Transaction.find_or_create_by!(
        user: user,
        category: category,
        kind: :expense,
        title: "#{title_base} (#{i}/#{installments})",
        amount: per_installment,
        occurred_on: occurred_on
      )
    end
  end
end

seed_installments!(
  user,
  category_name: "Compras",
  start_date: Date.current.beginning_of_month,
  max_installments: 48
)
