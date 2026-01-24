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
