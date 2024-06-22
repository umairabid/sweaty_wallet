# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
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

  resources :connectors, only: [:show] do
    member do
      post '/', to: 'connectors#create', as: 'create'
      get '/new', to: 'connectors#new', as: 'new'
    end
  end
end
