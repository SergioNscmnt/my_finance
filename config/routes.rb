Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :users, only: %i[new create]
  resource :session, only: %i[new create destroy]
  get "/session", to: redirect("/session/new")
  resource :account, only: %i[show update]
  resources :whatsapp_accounts, only: %i[create update destroy] do
    member do
      post :test_message
    end
  end

  resources :categories, except: %i[show]
  resources :category_budgets, only: %i[new edit create update destroy]
  resources :credit_card_invoices, only: [] do
    member do
      patch :pay
    end
  end
  resources :transactions, except: %i[show]
  get "transactions/import_statement_pdf", to: "transactions#import_statement_pdf", as: :import_statement_pdf_transactions
  post "transactions/import_statement_pdf", to: "transactions#create_statement_import", as: :create_statement_import_transactions
  get "search", to: "searches#index", as: :search
  get "search/preview", to: "searches#preview", as: :search_preview
  get "planning", to: "planning#index", as: :planning
  get "reports", to: "reports#index", as: :reports
  post "webhooks/evolution", to: "webhooks/evolution#create"
  get "dashboard", to: "dashboard#index"

  root "dashboard#index"
end
