Rails.application.routes.draw do

  root "welcome#index"

  get "teams/:id", to: "teams#show", as: "team"
  
  # users routes
  get "/users/new", to: "users#new", as: "new_user"
  post "/users", to: "users#create"
  # sessions routes
  get "/sign_in", to: "sessions#new"  
  post "/sessions", to: "sessions#create"
  delete "/sessions", to: "sessions#destroy", as: "logout"
end
