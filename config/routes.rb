Rails.application.routes.draw do
  mount Knock::Engine => "/knock"

  root "welcome#index"

# leagues routes
  get "/leagues/new", to: "leagues#new", as: "new_league"
  get "/leagues/myleague", to: "leagues#myleague", as: "league"
  get "/leagues/:id/view", to: "leagues#view", as: "view"
  post "/leagues/join", to: "leagues#join", as: "join"
  get "/leagues", to: "leagues#all"
  post "/leagues/create", to: "leagues#create"

# teams routes
  get "/teams/index", to: "teams#index"
  post "/teams", to: "teams#name"
  get "/teams", to: "teams#show", as: "team"
# users routes
  post "/users/", to: "users#create"

# sessions routes
  post "/sessions/create", to: "sessions#create"

# Admin routes
  get "/players/refresh", to: "players#refresh"
  get "/transfers/stoptransfers", to: "transfers#stoptransfers"
  get "/transfers/newgameweek", to: "transfers#newgameweek"

# transfer routes
  post "/transfers/bid", to: "transfers#bid", as: "bid"
  get  "/transfers/sell/:id", to: "transfers#sell", as: "sell"
end
