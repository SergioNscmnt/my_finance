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

ActiveRecord::Schema[7.1].define(version: 2026_02_07_173000) do
  create_table "allocation_targets", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "wallet_id", null: false
    t.integer "asset_class", null: false
    t.decimal "target_percentage", precision: 5, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["wallet_id", "asset_class"], name: "index_allocation_targets_on_wallet_id_and_asset_class", unique: true
    t.index ["wallet_id"], name: "index_allocation_targets_on_wallet_id"
  end

  create_table "assets", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "wallet_id", null: false
    t.string "name", null: false
    t.string "ticker", null: false
    t.integer "asset_type", null: false
    t.string "currency", default: "BRL", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["wallet_id", "ticker"], name: "index_assets_on_wallet_id_and_ticker", unique: true
    t.index ["wallet_id"], name: "index_assets_on_wallet_id"
  end

  create_table "categories", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.integer "kind", default: 0, null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_categories_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "category_budgets", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_category_budgets_on_category_id"
    t.index ["user_id", "category_id"], name: "index_category_budgets_on_user_id_and_category_id", unique: true
    t.index ["user_id"], name: "index_category_budgets_on_user_id"
  end

  create_table "dividends", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
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

  create_table "investment_goals", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
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

  create_table "investment_transactions", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
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

  create_table "market_instruments", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
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

  create_table "transactions", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
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

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "wallets", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "currency", default: "BRL", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  add_foreign_key "allocation_targets", "wallets"
  add_foreign_key "assets", "wallets"
  add_foreign_key "categories", "users"
  add_foreign_key "category_budgets", "categories"
  add_foreign_key "category_budgets", "users"
  add_foreign_key "dividends", "assets"
  add_foreign_key "dividends", "wallets"
  add_foreign_key "investment_goals", "wallets"
  add_foreign_key "investment_transactions", "assets"
  add_foreign_key "investment_transactions", "wallets"
  add_foreign_key "transactions", "categories"
  add_foreign_key "transactions", "users"
  add_foreign_key "wallets", "users"
end
