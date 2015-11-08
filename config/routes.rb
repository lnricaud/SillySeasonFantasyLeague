Rails.application.routes.draw do
  root "welcome#index"
# leagues routes
  get "/leagues/new", to: "leagues#new", as: "new_league"
  get "/leagues/:id/view", to: "leagues#view", as: "view"
  get "/leagues/:id", to: "leagues#show", as: "league"
  get "/leagues/:id/join", to: "leagues#join", as: "join"
  post "/leagues", to: "leagues#create"
# teams routes
  get "/teams/index", to: "teams#index"
  post "/teams", to: "teams#name"
# users routes
  get "/users/new", to: "users#new", as: "new_user"
  post "/users", to: "users#create"
# sessions routes
  get "/sign_in", to: "sessions#new"  
  post "/sessions", to: "sessions#create"
  delete "/sessions", to: "sessions#destroy", as: "logout"
# players routes
  get "/players/refresh", to: "players#refresh", as: "refresh"
  get "/players/players", to: "players#players", as: "players"
  get "/players/:id", to: "players#player", as: "player"
end
