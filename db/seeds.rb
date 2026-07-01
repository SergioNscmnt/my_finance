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
    "Animais de Estimação",
    "Outras despesas"
  ]
}

default_categories.each do |kind, names|
  names.each do |name|
    Category.find_or_create_by!(name: name, kind: kind, user: user)
  end
end

def find_category!(user, kind, name)
  Category.find_by!(user: user, kind: kind, name: name)
end

def seed_installment_purchase!(user, category_name:, occurred_on:, total_amount:, installments:)
  category = find_category!(user, :expense, category_name)

  Transaction.find_or_create_by!(
    user: user,
    category: category,
    kind: :expense,
    title: "Compra parcelada #{installments}x",
    amount: total_amount,
    occurred_on: occurred_on,
    payment_method: :credit_card,
    installments: installments
  )
end

def seed_expense!(user, category_name:, title:, amount:, occurred_on:, payment_method: :cash)
  category = find_category!(user, :expense, category_name)

  Transaction.find_or_create_by!(
    user: user,
    category: category,
    kind: :expense,
    title: title,
    amount: amount,
    occurred_on: occurred_on,
    payment_method: payment_method,
    installments: 1
  )
end

def seed_income!(user, category_name:, title:, amount:, occurred_on:, payment_method: :pix)
  category = find_category!(user, :income, category_name)

  Transaction.find_or_create_by!(
    user: user,
    category: category,
    kind: :income,
    title: title,
    amount: amount,
    occurred_on: occurred_on,
    payment_method: payment_method,
    installments: 1
  )
end

month_start = Date.current.beginning_of_month

seed_installment_purchase!(user, category_name: "Compras", occurred_on: month_start - 2.months, total_amount: 1800.0, installments: 6)
seed_installment_purchase!(user, category_name: "Lazer", occurred_on: month_start - 5.months, total_amount: 2400.0, installments: 10)

seed_expense!(user, category_name: "Moradia", title: "Aluguel", amount: 2500.0, occurred_on: month_start - 6.months)
seed_expense!(user, category_name: "Contas e Serviços", title: "Conta de luz", amount: 320.45, occurred_on: month_start - 6.months + 3.days)
seed_expense!(user, category_name: "Alimentação", title: "Supermercado", amount: 680.30, occurred_on: month_start - 5.months + 8.days)
seed_expense!(user, category_name: "Transporte", title: "Combustível", amount: 410.0, occurred_on: month_start - 4.months + 5.days, payment_method: :pix)
seed_expense!(user, category_name: "Saúde", title: "Farmácia", amount: 155.9, occurred_on: month_start - 3.months + 12.days)
seed_expense!(user, category_name: "Educação", title: "Curso online", amount: 289.0, occurred_on: month_start - 2.months + 18.days, payment_method: :pix)
seed_expense!(user, category_name: "Compras", title: "Eletrônicos", amount: 950.0, occurred_on: month_start - 1.month + 6.days, payment_method: :credit_card)
seed_expense!(user, category_name: "Lazer", title: "Restaurantes", amount: 220.0, occurred_on: month_start + 2.days)
seed_expense!(user, category_name: "Saúde", title: "Consulta médica", amount: 280.0, occurred_on: month_start + 9.days, payment_method: :pix)
seed_expense!(user, category_name: "Alimentação", title: "Feira", amount: 210.0, occurred_on: month_start - 1.month + 12.days)
seed_expense!(user, category_name: "Contas e Serviços", title: "Internet", amount: 129.9, occurred_on: month_start - 1.month + 3.days)
seed_expense!(user, category_name: "Transporte", title: "App mobilidade", amount: 95.0, occurred_on: month_start - 2.months + 9.days)
seed_expense!(user, category_name: "Moradia", title: "Condomínio", amount: 420.0, occurred_on: month_start - 3.months + 5.days)
seed_expense!(user, category_name: "Lazer", title: "Cinema", amount: 78.0, occurred_on: month_start - 4.months + 16.days)
seed_expense!(user, category_name: "Educação", title: "Livro técnico", amount: 145.0, occurred_on: month_start - 5.months + 22.days)
seed_expense!(user, category_name: "Saúde", title: "Exames", amount: 360.0, occurred_on: month_start - 6.months + 18.days)
seed_expense!(user, category_name: "Alimentação", title: "Restaurante", amount: 190.0, occurred_on: month_start + 5.days, payment_method: :pix)
seed_expense!(user, category_name: "Compras", title: "Vestuário", amount: 320.0, occurred_on: month_start + 11.days, payment_method: :credit_card)

seed_income!(user, category_name: "Salário", title: "Salário", amount: 7500.0, occurred_on: month_start - 6.months + 2.days)
seed_income!(user, category_name: "Salário", title: "Salário", amount: 7600.0, occurred_on: month_start - 3.months + 2.days)
seed_income!(user, category_name: "Freelance", title: "Projeto extra", amount: 1800.0, occurred_on: month_start - 2.months + 20.days)
seed_income!(user, category_name: "Salário", title: "Salário", amount: 7800.0, occurred_on: month_start + 1.day)
