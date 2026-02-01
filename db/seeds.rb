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

wallet = user.wallets.find_or_create_by!(name: "Principal") do |w|
  w.currency = "BRL"
end

assets = [
  { name: "Petrobras PN", ticker: "PETR4", asset_type: :stock },
  { name: "Itaúsa PN", ticker: "ITSA4", asset_type: :stock },
  { name: "FII Kinea Renda Imobiliária", ticker: "KNRI11", asset_type: :fii },
  { name: "Tesouro Selic 2029", ticker: "LFT2029", asset_type: :fixed_income },
  { name: "Bitcoin", ticker: "BTC", asset_type: :crypto }
]

seed_assets = assets.map do |attrs|
  wallet.assets.find_or_create_by!(ticker: attrs[:ticker]) do |asset|
    asset.name = attrs[:name]
    asset.asset_type = attrs[:asset_type]
    asset.currency = "BRL"
  end
end

def seed_investment_transaction!(wallet:, asset:, kind:, quantity:, price:, occurred_on:, fees: 0)
  InvestmentTransaction.find_or_create_by!(
    wallet: wallet,
    asset: asset,
    kind: kind,
    quantity: quantity,
    price: price,
    fees: fees,
    occurred_on: occurred_on
  )
end

def seed_dividend!(wallet:, asset:, kind:, amount:, paid_on:, reinvested: false)
  Dividend.find_or_create_by!(
    wallet: wallet,
    asset: asset,
    kind: kind,
    amount: amount,
    paid_on: paid_on,
    reinvested: reinvested
  )
end

base_date = Date.current.beginning_of_year

seed_assets.each do |asset|
  case asset.ticker
  when "PETR4"
    seed_investment_transaction!(wallet: wallet, asset: asset, kind: :buy, quantity: 120, price: 32.15, fees: 8.5, occurred_on: base_date + 12.days)
    seed_investment_transaction!(wallet: wallet, asset: asset, kind: :buy, quantity: 80, price: 34.10, fees: 6.0, occurred_on: base_date + 80.days)
    seed_dividend!(wallet: wallet, asset: asset, kind: :dividend, amount: 210.45, paid_on: base_date + 120.days)
  when "ITSA4"
    seed_investment_transaction!(wallet: wallet, asset: asset, kind: :buy, quantity: 200, price: 10.55, fees: 5.0, occurred_on: base_date + 20.days)
    seed_investment_transaction!(wallet: wallet, asset: asset, kind: :buy, quantity: 150, price: 11.20, fees: 5.0, occurred_on: base_date + 110.days)
    seed_dividend!(wallet: wallet, asset: asset, kind: :dividend, amount: 55.25, paid_on: base_date + 150.days)
  when "KNRI11"
    seed_investment_transaction!(wallet: wallet, asset: asset, kind: :buy, quantity: 30, price: 160.70, fees: 7.5, occurred_on: base_date + 40.days)
    seed_investment_transaction!(wallet: wallet, asset: asset, kind: :buy, quantity: 20, price: 167.20, fees: 7.5, occurred_on: base_date + 100.days)
    seed_dividend!(wallet: wallet, asset: asset, kind: :dividend, amount: 98.40, paid_on: base_date + 130.days)
    seed_dividend!(wallet: wallet, asset: asset, kind: :dividend, amount: 102.30, paid_on: base_date + 160.days)
  when "LFT2029"
    seed_investment_transaction!(wallet: wallet, asset: asset, kind: :buy, quantity: 1.5, price: 1000.00, fees: 0, occurred_on: base_date + 10.days)
    seed_investment_transaction!(wallet: wallet, asset: asset, kind: :buy, quantity: 1.0, price: 1025.00, fees: 0, occurred_on: base_date + 200.days)
    seed_dividend!(wallet: wallet, asset: asset, kind: :interest, amount: 32.80, paid_on: base_date + 210.days)
  when "BTC"
    seed_investment_transaction!(wallet: wallet, asset: asset, kind: :buy, quantity: 0.12, price: 180_000.00, fees: 15.0, occurred_on: base_date + 60.days)
    seed_investment_transaction!(wallet: wallet, asset: asset, kind: :buy, quantity: 0.08, price: 200_000.00, fees: 12.0, occurred_on: base_date + 170.days)
  end
end

positions = Investments::PositionCalculator.new(wallet: wallet).call
invested_total = positions.sum(&:invested_amount).to_d
invested_total = 1_000.to_d if invested_total <= 0

investment_goals = [
  {
    name: "Reserva de emergência",
    goal_type: :reserve,
    target_amount: (invested_total * 1.5).round(2),
    target_date: Date.current + 18.months,
    monthly_contribution: (invested_total * 0.08).round(2)
  },
  {
    name: "Independência financeira",
    goal_type: :freedom,
    target_amount: (invested_total * 6).round(2),
    target_date: Date.current + 8.years,
    monthly_contribution: (invested_total * 0.12).round(2)
  },
  {
    name: "Aposentadoria",
    goal_type: :retirement,
    target_amount: (invested_total * 12).round(2),
    target_date: Date.current + 18.years,
    monthly_contribution: (invested_total * 0.15).round(2)
  }
]

investment_goals.each do |goal|
  wallet.investment_goals.find_or_create_by!(name: goal[:name]) do |record|
    record.goal_type = goal[:goal_type]
    record.target_amount = goal[:target_amount]
    record.target_date = goal[:target_date]
    record.monthly_contribution = goal[:monthly_contribution]
  end
end

allocation = Investments::AllocationCalculator.new(positions: positions).call
allocation.each do |asset_class, share|
  wallet.allocation_targets.find_or_create_by!(asset_class: asset_class) do |target|
    target.target_percentage = (share * 100).round(2)
  end
end
