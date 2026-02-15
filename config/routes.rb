Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :users, only: %i[new create]
  resource :session, only: %i[new create destroy]
  resource :account, only: %i[show update]

  resources :categories, except: %i[show]
  resources :category_budgets, only: %i[edit create update destroy]
  resources :transactions, except: %i[show]
  get "dashboard", to: "dashboard#index"
  get "investments/portfolio", to: "investments#portfolio"
  get "investments/analysis", to: "investments#analysis"
  get "investments/planning", to: "investments#planning"
  get "investments/income", to: "investments#income"
  get "investments/dividends", to: "investments#dividends"
  get "investments/integrations", to: "investments#integrations"
  post "investments/integrations/sync_massive", to: "investments#sync_massive", as: :investments_sync_massive
  post "investments/integrations/sync_instruments", to: "investments#sync_instruments", as: :investments_sync_instruments
  get "investments/buy", to: "investments#new_buy", as: :new_investments_buy
  post "investments/buy", to: "investments#create_buy", as: :investments_buy
  get "investments/instruments/search", to: "investments#search_instruments", as: :investments_instruments_search

  resources :assets do
    resources :investment_transactions, except: %i[index show]
    resources :dividends, except: %i[index show]
  end

  root "dashboard#index"
end
