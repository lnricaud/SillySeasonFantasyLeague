Rails.application.routes.draw do
  # JWT routes
  mount Knock::Engine => "/knock"
  get "/api/random-quote", to: "sessions#random_quote"
  get "/api/protected/random-quote", to: "transfers#protected"
  post "/users/", to: "users#create"

  root "welcome#index"
# leagues routes
  get "/leagues/new", to: "leagues#new", as: "new_league"
  get "/leagues/myleague", to: "leagues#myleague", as: "league"
  get "/leagues/:id/view", to: "leagues#view", as: "view"
  post "/leagues/join", to: "leagues#join", as: "join"
  get "/leagues", to: "leagues#all" # used by Angular 2 for getting all leagues
  post "/leagues/create", to: "leagues#create"
  # post "/leagues", to: "leagues#create"
# teams routes
  get "/teams/index", to: "teams#index"
  post "/teams", to: "teams#name"
  get "/teams", to: "teams#show", as: "team"
# users routes
  get "/users/new", to: "users#new", as: "new_user"
  get "/users/quicklogin/:email", to: "users#quicklogin", as: "quicklogin"
  # post "/users/", to: "users#create"

# sessions routes
  post "/sessions/create", to: "sessions#create"

# players routes
  get "/players/refresh", to: "players#refresh", as: "refresh"
  get "/players/players", to: "players#players", as: "players"
  get "/players/:id", to: "players#player", as: "player"
# transfer routes
  get "/transfers", to: "transfers#index", as: "transfers"
  get "/transfers/stoptransfers", to: "transfers#stoptransfers", as: "stop"
  get "/transfers/newgameweek", to: "transfers#newgameweek", as: "newgameweek"
  post "/transfers/bid", to: "transfers#bid", as: "bid"
  get  "/transfers/sell/:id", to: "transfers#sell", as: "sell"
end
