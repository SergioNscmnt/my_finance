# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_03_01_120000) do
  create_table "allocation_targets", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "wallet_id", null: false
    t.integer "asset_class", null: false
    t.decimal "target_percentage", precision: 5, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["wallet_id", "asset_class"], name: "index_allocation_targets_on_wallet_id_and_asset_class", unique: true
    t.index ["wallet_id"], name: "index_allocation_targets_on_wallet_id"
  end

  create_table "assets", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "wallet_id", null: false
    t.string "name", null: false
    t.string "ticker", null: false
    t.integer "asset_type", null: false
    t.string "currency", default: "BRL", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "asset_class", default: 0, null: false
    t.string "symbol", null: false
    t.string "exchange"
    t.integer "status", default: 0, null: false
    t.index ["asset_class"], name: "index_assets_on_asset_class"
    t.index ["status"], name: "index_assets_on_status"
    t.index ["symbol", "exchange"], name: "index_assets_on_symbol_and_exchange", unique: true
    t.index ["wallet_id", "ticker"], name: "index_assets_on_wallet_id_and_ticker", unique: true
    t.index ["wallet_id"], name: "index_assets_on_wallet_id"
  end

  create_table "candles", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "asset_id", null: false
    t.string "timeframe", null: false
    t.datetime "timestamp", null: false
    t.decimal "open", precision: 20, scale: 8, null: false
    t.decimal "high", precision: 20, scale: 8, null: false
    t.decimal "low", precision: 20, scale: 8, null: false
    t.decimal "close", precision: 20, scale: 8, null: false
    t.decimal "volume", precision: 24, scale: 8
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id", "timeframe", "timestamp"], name: "index_candles_on_asset_timeframe_timestamp", unique: true
    t.index ["asset_id", "timeframe"], name: "index_candles_on_asset_id_and_timeframe"
    t.index ["asset_id"], name: "index_candles_on_asset_id"
  end

  create_table "cash_accounts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "portfolio_id", null: false
    t.string "currency", null: false
    t.decimal "balance", precision: 20, scale: 8, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["portfolio_id", "currency"], name: "index_cash_accounts_on_portfolio_id_and_currency", unique: true
    t.index ["portfolio_id"], name: "index_cash_accounts_on_portfolio_id"
  end

  create_table "categories", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.integer "kind", default: 0, null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "credit_card", default: false, null: false
    t.integer "statement_closing_day"
    t.integer "statement_due_day"
    t.integer "reminder_days_before_due", default: 5, null: false
    t.string "card_bank"
    t.index ["user_id", "card_bank"], name: "index_categories_on_user_id_and_card_bank", unique: true
    t.index ["user_id", "name"], name: "index_categories_on_user_id_and_name"
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "category_budgets", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "budget_month", null: false
    t.index ["category_id"], name: "index_category_budgets_on_category_id"
    t.index ["user_id", "category_id", "budget_month"], name: "index_category_budgets_on_user_category_month", unique: true
    t.index ["user_id"], name: "index_category_budgets_on_user_id"
  end

  create_table "credit_card_invoices", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.date "billing_month", null: false
    t.date "due_on", null: false
    t.decimal "total_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.integer "status", default: 0, null: false
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id", "billing_month"], name: "index_credit_card_invoices_on_category_id_and_billing_month", unique: true
    t.index ["category_id"], name: "index_credit_card_invoices_on_category_id"
    t.index ["user_id", "due_on"], name: "index_credit_card_invoices_on_user_id_and_due_on"
    t.index ["user_id", "status"], name: "index_credit_card_invoices_on_user_id_and_status"
    t.index ["user_id"], name: "index_credit_card_invoices_on_user_id"
  end

  create_table "dividends", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "wallet_id", null: false
    t.bigint "asset_id", null: false
    t.integer "kind", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.date "paid_on", null: false
    t.boolean "reinvested", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id"], name: "index_dividends_on_asset_id"
    t.index ["wallet_id", "paid_on"], name: "index_dividends_on_wallet_id_and_paid_on"
    t.index ["wallet_id"], name: "index_dividends_on_wallet_id"
  end

  create_table "fx_rates", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "base_currency", null: false
    t.string "quote_currency", null: false
    t.decimal "rate", precision: 20, scale: 10, null: false
    t.date "rate_date", null: false
    t.string "provider", default: "frankfurter", null: false
    t.datetime "retrieved_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["base_currency", "quote_currency", "rate_date"], name: "index_fx_rates_on_pair_and_rate_date", unique: true
    t.index ["base_currency", "quote_currency", "retrieved_at"], name: "index_fx_rates_on_pair_and_retrieved_at"
  end

  create_table "investment_goals", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "wallet_id", null: false
    t.string "name", null: false
    t.integer "goal_type", default: 3, null: false
    t.decimal "target_amount", precision: 15, scale: 2, null: false
    t.date "target_date", null: false
    t.decimal "monthly_contribution", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["wallet_id"], name: "index_investment_goals_on_wallet_id"
  end

  create_table "investment_transactions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "wallet_id", null: false
    t.bigint "asset_id", null: false
    t.integer "kind", null: false
    t.decimal "quantity", precision: 15, scale: 6, null: false
    t.decimal "price", precision: 15, scale: 6, null: false
    t.decimal "fees", precision: 12, scale: 2, default: "0.0", null: false
    t.date "occurred_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id", "occurred_on"], name: "index_investment_transactions_on_asset_id_and_occurred_on"
    t.index ["asset_id"], name: "index_investment_transactions_on_asset_id"
    t.index ["wallet_id", "occurred_on"], name: "index_investment_transactions_on_wallet_id_and_occurred_on"
    t.index ["wallet_id"], name: "index_investment_transactions_on_wallet_id"
  end

  create_table "ledger_entries", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "portfolio_id", null: false
    t.integer "entry_type", null: false
    t.string "currency", null: false
    t.decimal "amount", precision: 20, scale: 8, null: false
    t.text "metadata", size: :long, collation: "utf8mb4_bin"
    t.datetime "occurred_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["portfolio_id", "entry_type", "occurred_at"], name: "index_ledger_entries_on_portfolio_type_date"
    t.index ["portfolio_id", "occurred_at"], name: "index_ledger_entries_on_portfolio_id_and_occurred_at"
    t.index ["portfolio_id"], name: "index_ledger_entries_on_portfolio_id"
    t.check_constraint "json_valid(`metadata`)", name: "metadata"
  end

  create_table "market_instruments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "ticker", null: false
    t.string "name", null: false
    t.integer "asset_type", null: false
    t.string "market"
    t.string "locale"
    t.string "currency", default: "USD", null: false
    t.boolean "active", default: true, null: false
    t.datetime "last_synced_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_market_instruments_on_active"
    t.index ["asset_type"], name: "index_market_instruments_on_asset_type"
    t.index ["ticker"], name: "index_market_instruments_on_ticker", unique: true
  end

  create_table "orders", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "portfolio_id", null: false
    t.bigint "asset_id", null: false
    t.integer "side", null: false
    t.decimal "quantity", precision: 24, scale: 10, null: false
    t.integer "status", default: 0, null: false
    t.decimal "filled_price", precision: 20, scale: 8
    t.decimal "fees", precision: 20, scale: 8, default: "0.0", null: false
    t.string "provider"
    t.datetime "provider_quote_timestamp"
    t.datetime "requested_at", null: false
    t.datetime "filled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id", "requested_at"], name: "index_orders_on_asset_id_and_requested_at"
    t.index ["asset_id"], name: "index_orders_on_asset_id"
    t.index ["portfolio_id", "status", "requested_at"], name: "index_orders_on_portfolio_id_and_status_and_requested_at"
    t.index ["portfolio_id"], name: "index_orders_on_portfolio_id"
  end

  create_table "portfolios", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "base_currency", default: "BRL", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["base_currency"], name: "index_portfolios_on_base_currency"
    t.index ["user_id"], name: "index_portfolios_on_user_id"
  end

  create_table "positions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "portfolio_id", null: false
    t.bigint "asset_id", null: false
    t.decimal "quantity", precision: 24, scale: 10, default: "0.0", null: false
    t.decimal "avg_cost", precision: 20, scale: 8, default: "0.0", null: false
    t.string "currency", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id"], name: "index_positions_on_asset_id"
    t.index ["portfolio_id", "asset_id"], name: "index_positions_on_portfolio_id_and_asset_id", unique: true
    t.index ["portfolio_id", "currency"], name: "index_positions_on_portfolio_id_and_currency"
    t.index ["portfolio_id"], name: "index_positions_on_portfolio_id"
  end

  create_table "quotes", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "asset_id", null: false
    t.decimal "price", precision: 20, scale: 8, null: false
    t.decimal "change_percent", precision: 12, scale: 6
    t.string "provider", null: false
    t.datetime "provider_timestamp", null: false
    t.datetime "retrieved_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id", "provider_timestamp"], name: "index_quotes_on_asset_id_and_provider_timestamp"
    t.index ["asset_id", "retrieved_at"], name: "index_quotes_on_asset_id_and_retrieved_at"
    t.index ["asset_id"], name: "index_quotes_on_asset_id"
  end

  create_table "transactions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.integer "kind", null: false
    t.date "occurred_on", null: false
    t.bigint "category_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "payment_method", default: 0, null: false
    t.integer "installments", default: 1, null: false
    t.index ["category_id"], name: "index_transactions_on_category_id"
    t.index ["kind"], name: "index_transactions_on_kind"
    t.index ["user_id", "occurred_on"], name: "index_transactions_on_user_id_and_occurred_on"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "wallets", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "currency", default: "BRL", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  add_foreign_key "allocation_targets", "wallets"
  add_foreign_key "assets", "wallets"
  add_foreign_key "candles", "assets"
  add_foreign_key "cash_accounts", "portfolios"
  add_foreign_key "categories", "users"
  add_foreign_key "category_budgets", "categories"
  add_foreign_key "category_budgets", "users"
  add_foreign_key "credit_card_invoices", "categories"
  add_foreign_key "credit_card_invoices", "users"
  add_foreign_key "dividends", "assets"
  add_foreign_key "dividends", "wallets"
  add_foreign_key "investment_goals", "wallets"
  add_foreign_key "investment_transactions", "assets"
  add_foreign_key "investment_transactions", "wallets"
  add_foreign_key "ledger_entries", "portfolios"
  add_foreign_key "orders", "assets"
  add_foreign_key "orders", "portfolios"
  add_foreign_key "portfolios", "users"
  add_foreign_key "positions", "assets"
  add_foreign_key "positions", "portfolios"
  add_foreign_key "quotes", "assets"
  add_foreign_key "transactions", "categories"
  add_foreign_key "transactions", "users"
  add_foreign_key "wallets", "users"
end
