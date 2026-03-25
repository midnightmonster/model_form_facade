Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resource :contact, only: [:show, :update], controller: "contacts"
  resources :workshops
  resources :registrations, only: [:index, :new, :create, :edit, :update]
  resources :pages
  resources :validated_workshops, only: [:new, :create, :edit, :update]

  root "workshops#index"
end
