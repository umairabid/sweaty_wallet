# frozen_string_literal: true

Rails.application.routes.draw do
  mount GoodJob::Engine => 'good_job'
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  root 'dashboard#index'

  get 'dashboard/index'

  devise_scope :user do
    get 'users/sign_in' => 'devise/sessions#new', :as => :login
  end

  resources :connectors, only: %i[index new create] do
    collection do
      post :import
      post :import_csv
    end
  end

  resources :financial_assets

  resources :accounts, only: %i[index update destroy] do
    member do
      post :merge
    end
  end

  resources :transactions do
    collection do
      get :export
      post :suggest_categories
    end
  end

  resources :transaction_rules do
    member do
      post :apply
      post :conditions
      get :preview
      get :next
      delete :delete_condition
    end
  end

  resources :categories

  resources :blocking_jobs, only: %(show)
end
