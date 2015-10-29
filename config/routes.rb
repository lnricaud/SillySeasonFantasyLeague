Rails.application.routes.draw do
  root "welcome#index"
# leagues routes
  get "/leagues/new", to: "leagues#new", as: "new_league"
  post "/leagues", to: "leagues#create"
  get "/leagues/:id", to: "leagues#show", as: "league"
  get "/leagues/:id/join", to: "leagues#join", as: "join"
# teams routes
  post "/teams", to: "teams#tname"
  get "/teams/:id", to: "teams#show", as: "team"
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
