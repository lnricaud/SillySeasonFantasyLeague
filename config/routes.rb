Rails.application.routes.draw do

  get 'leagues/create'

  root "welcome#index"

  post "/leagues", to: "leagues#create"
  get "teams/:id", to: "teams#show", as: "team"
  
  # users routes
  get "/users/new", to: "users#new", as: "new_user"
  post "/users", to: "users#create"
  # sessions routes
  get "/sign_in", to: "sessions#new"  
  post "/sessions", to: "sessions#create"
  delete "/sessions", to: "sessions#destroy", as: "logout"
end
