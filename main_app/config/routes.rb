# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {
            registrations: "users/registrations",
          }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "dashboard#index"

  get "dashboard/index"

  devise_scope :user do
    get "users/sign_in" => "devise/sessions#new", :as => :login
  end

  resources :connect, param: :bank, controller: "connectors", only: %i[show update] do
    member do
      post "/direct" => "connectors#create_direct", as: :create_direct
      get "/extension/new" => "connectors#new_extension", as: :new_extension
      get "/direct/new" => "connectors#new_direct", as: :new_direct
    end
  end

  resources :accounts, only: %i[index update] do
    collection do
      post :import
    end
  end

  resources :transactions, only: %i[index update edit] do
    collection do
      get :export
    end
  end

  resources :transaction_rules do
    member do
      post :apply
      post :conditions
      get :preview
      delete :delete_condition
    end
  end

  resources :categories
end
