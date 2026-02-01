Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :users, only: %i[new create]
  resource :session, only: %i[new create destroy]
  resource :account, only: %i[show update]

  resources :categories, except: %i[show]
  resources :transactions, except: %i[show]
  get "dashboard", to: "dashboard#index"
  get "investments/portfolio", to: "investments#portfolio"
  get "investments/analysis", to: "investments#analysis"
  get "investments/planning", to: "investments#planning"
  get "investments/income", to: "investments#income"
  get "investments/dividends", to: "investments#dividends"
  get "investments/integrations", to: "investments#integrations"

  resources :assets do
    resources :investment_transactions, except: %i[index show]
    resources :dividends, except: %i[index show]
  end

  root "dashboard#index"
end
