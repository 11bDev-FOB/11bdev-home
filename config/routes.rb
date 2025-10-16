Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA routes  
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Root route
  root "pages#home"

  # Static pages
  get "about", to: "pages#about"
  get "contact", to: "pages#contact"
  get "smb", to: "pages#smb"
  get "legal", to: "pages#legal"

  # Sitrep page
  get "sitrep", to: "sitrep#index"
  post "sitrep/refresh", to: "sitrep#refresh"

  # Projects
  resources :projects, only: [:index, :show]
  
  # Admin backoffice (must come before blog routes to avoid conflicts)
  namespace :admin do
    root "dashboard#index"
    resources :posts
    resources :projects
  end
  
  # Blog (comes after admin to avoid route conflicts)
  resources :posts, only: [:index, :show], path: "blog"
  
  # API endpoints
  namespace :api, defaults: { format: :json } do
    resources :posts, only: [:index, :show, :create, :update, :destroy]
    resources :projects, only: [:index, :show, :create, :update, :destroy]
  end
end
