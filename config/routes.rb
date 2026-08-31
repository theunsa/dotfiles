Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  # Public client-facing routes. The slug is the whole security model.
  scope "d/:slug" do
    get "", to: "dossiers#show", as: :dossier
    get "unlock", to: "unlocks#new", as: :dossier_unlock
    post "unlock", to: "unlocks#create"
    post "acceptances", to: "acceptances#create", as: :dossier_acceptances
  end

  namespace :admin do
    root "dossiers#index"
    resources :dossiers
  end
end
