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
    "Animais de Estimação",
    "Investimentos (despesa)",
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

wallet = user.wallets.find_or_create_by!(name: "Principal") do |w|
  w.currency = "BRL"
end

assets = [
  { name: "Apple Inc.", ticker: "AAPL", asset_type: :stock, currency: "USD" },
  { name: "Microsoft Corporation", ticker: "MSFT", asset_type: :stock, currency: "USD" },
  { name: "NVIDIA Corporation", ticker: "NVDA", asset_type: :stock, currency: "USD" },
  { name: "SPDR S&P 500 ETF Trust", ticker: "SPY", asset_type: :fund, currency: "USD" },
  { name: "Bitcoin", ticker: "BTC", asset_type: :crypto, currency: "USD" }
]

seed_assets = assets.map do |attrs|
  wallet.assets.find_or_create_by!(ticker: attrs[:ticker]) do |asset|
    asset.name = attrs[:name]
    asset.asset_type = attrs[:asset_type]
    asset.currency = attrs[:currency] || "USD"
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

def seed_portfolio!(wallet:, seed_assets:)
  fx_rate = Frankfurter::MarketDataService.new.quote_for(seed_assets.first)[:exchange_rate].to_d
  fx_rate = BigDecimal("5.0") if fx_rate <= 0

  seed_assets.each_with_index do |asset, index|
    base_price = asset.crypto? ? BigDecimal("45000") : BigDecimal((100 + (index * 40)).to_s)
    price = (base_price * fx_rate).round(2)
    quantity = asset.crypto? ? BigDecimal("0.05") : BigDecimal((10 + index * 2).to_s)

    seed_investment_transaction!(
      wallet: wallet,
      asset: asset,
      kind: :buy,
      quantity: quantity,
      price: price,
      fees: 2.5,
      occurred_on: Date.current - (100 - index * 5).days
    )

    next if asset.crypto?

    seed_dividend!(
      wallet: wallet,
      asset: asset,
      kind: :dividend,
      amount: (price * 0.008).round(2),
      paid_on: Date.current - (20 - index).days
    )
  end
end

seed_portfolio!(wallet: wallet, seed_assets: seed_assets)

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
  next if share.to_d <= 0
  wallet.allocation_targets.find_or_create_by!(asset_class: asset_class) do |target|
    target.target_percentage = (share * 100).round(2)
  end
end
