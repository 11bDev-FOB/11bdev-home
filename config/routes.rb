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
  get "opensource", to: "pages#opensource"

  # Sitrep page
  get "sitrep", to: "sitrep#index"
  post "sitrep/refresh", to: "sitrep#refresh"

  # Projects
  resources :projects, only: [:index, :show]

  # Contact form
end
