Rails.application.routes.draw do
  root "welcome#index"
# leagues routes
  get "/leagues/new", to: "leagues#new", as: "new_league"
  get "/leagues/:id", to: "leagues#show", as: "league"
  get "/leagues/:id/view", to: "leagues#view", as: "view"
  get "/leagues/:id/join", to: "leagues#join", as: "join"
  post "/leagues", to: "leagues#create"
# teams routes
  get "/teams/index", to: "teams#index"
  post "/teams", to: "teams#name"
  get "/teams", to: "teams#show", as: "team"
# users routes
  get "/users/new", to: "users#new", as: "new_user"
  get "/users/quicklogin/:email", to: "users#quicklogin", as: "quicklogin"
  post "/users/", to: "users#create"

# sessions routes
  get "/sign_in", to: "sessions#new"  
  post "/sessions", to: "sessions#create"
  delete "/sessions", to: "sessions#destroy", as: "logout"
# players routes
  get "/players/refresh", to: "players#refresh", as: "refresh"
  get "/players/players", to: "players#players", as: "players"
  get "/players/:id", to: "players#player", as: "player"
# transfer routes
  get "/transfers", to: "transfers#index", as: "transfers"
  get "/transfers/stoptransfers", to: "transfers#stoptransfers", as: "stop"
  get "/transfers/newgameweek", to: "transfers#newgameweek", as: "newgameweek"
  get "/transfers/bid/:id", to: "transfers#bid", as: "bid"
  get  "/transfers/sell/:id", to: "transfers#sell", as: "sell"
end
