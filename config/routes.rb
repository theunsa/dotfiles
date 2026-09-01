Rails.application.routes.draw do
  # No password-reset routes: single-author tool, no SMTP anywhere in the stack.
  # Recovery is `bin/rails dossier:user[email]` on the box (see README).
  resource :session

  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  # Public client-facing routes. The slug is the whole security model.
  scope "d/:slug" do
    get "", to: "dossiers#show", as: :dossier
    get "unlock", to: "unlocks#new", as: :dossier_unlock
    post "unlock", to: "unlocks#create"
  end

  namespace :admin do
    root "dossiers#index"
    resources :dossiers
    # POST, not GET: the markdown being previewed is unsaved and too long for a URL.
    resource :preview, only: :create
  end
end
