Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :users, only: %i[new create]
  resource :session, only: %i[new create destroy]
  resource :account, only: %i[show update]

  resources :categories, except: %i[show]
  resources :transactions, except: %i[show]
  get "dashboard", to: "dashboard#index"
  namespace :ai do
    resource :consultant, only: :create, controller: "consultant"
  end

  root "dashboard#index"
end
