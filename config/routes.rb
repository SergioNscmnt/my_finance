Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :users, only: %i[new create]
  resource :session, only: %i[new create destroy]
  resource :account, only: %i[show update]

  resources :categories, except: %i[show]
  resources :category_budgets, only: %i[edit create update destroy]
  resources :credit_card_invoices, only: [] do
    member do
      patch :pay
    end
  end
  resources :transactions, except: %i[show]
  get "transactions/import_statement_pdf", to: "transactions#import_statement_pdf", as: :import_statement_pdf_transactions
  post "transactions/import_statement_pdf", to: "transactions#create_statement_import", as: :create_statement_import_transactions
  get "dashboard", to: "dashboard#index"
  get "investments/portfolio", to: "investments#portfolio"
  get "investments/analysis", to: "investments#analysis"
  get "investments/planning", to: "investments#planning"
  get "investments/income", to: "investments#income"
  get "investments/dividends", to: "investments#dividends"
  get "investments/integrations", to: "investments#integrations"
  get "investments/live_rates", to: "investments#live_rates"

  resources :assets do
    collection do
      get "tickers/search", to: "assets#search_tickers", as: :tickers_search
    end
    member do
      get :live_quote
    end
    resources :investment_transactions, except: %i[index show]
    resources :dividends, except: %i[index show]
  end

  root "dashboard#index"
end
