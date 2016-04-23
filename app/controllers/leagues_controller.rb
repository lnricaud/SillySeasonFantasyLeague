class LeaguesController < ApplicationController
	# before_action :authenticate

	def create
		require 'player'
		require 'yaml'
		user = current_user
		p "--- in leagues#create ---"
		p "#{params}"
		p "user.email: #{user.email}"
		p "create league params: #{params}"
		p "current_user.id #{user.id}"
		# league_params = {:league_name => params["league"]["league_name"], :user_id => user.id, }
		league_params = params.permit(:league_name, :password)
		league_params[:user_id] = user.id
		# adding players
		this_leagues_players = Hash.new
		$playerdata.each {|id, player| this_leagues_players[id] = Player.new(id)}
		league_params[:players] = YAML::dump this_leagues_players
		
		p "CREATING A LEAGUE: #{league_params}"
		league = League.create(league_params)
		p "League created? #{!league.nil?}, id: #{league.id}"
		if league.id.nil?
			p "ERROR! League not created!"
			# redirect_to "/leagues/new"
			render json: {error: "League not created: #{params}"}, status: :unprocessable_entity
		else # League Successfully created
			updated_attributes = {:league_id => league.id}
			user.update_attributes(updated_attributes)
			
			# Create new token that includes the 
			hmac_secret = '4eda0940f4b680eaa3573abedb9d34dc5f878d241335c4f9ef189fd0c874e078ad1a658f81853b69a6334b2109c3bc94852997c7380ccdebbe85d766947fde69' # TODO: move this to env
			payload = {name: user.name, email: user.email, id: user.id, team_name: user.team_name, league_id: user.league_id}
			p "payload: #{payload}"
			token = JWT.encode payload, hmac_secret, 'HS256'

			render json: {id_token: token} 
		end
	end

  def join
  	# TODO: Make sure team names are unique
  	p "join league params: #{params}"
  	user = current_user
  	p "user.email #{user.email}"
  	league_params = params.permit(:league_id, :password)
  	p "Trying to verify league =============================="
  	p "league_params: #{league_params}"
  	league = League.confirm(league_params)
	  p "confirmed league?: #{league}"
  	if league
	  	p "league.id #{params["id"]}"
	  	updated_attributes = {:league_id => league.id}
	  	user.update_attributes(updated_attributes)
	  	Log.create(action: "joined", game_week: $current_gameweek, user_id: user.id, league_id: league.id, message: "#{user.name} joined #{league.league_name} with team #{user.team_name}")

			hmac_secret = '4eda0940f4b680eaa3573abedb9d34dc5f878d241335c4f9ef189fd0c874e078ad1a658f81853b69a6334b2109c3bc94852997c7380ccdebbe85d766947fde69' # TODO: move this to env
			payload = {name: user.name, email: user.email, id: user.id, team_name: user.team_name, league_id: user.league_id}
			p "payload: #{payload}"
			token = JWT.encode payload, hmac_secret, 'HS256'

			p "Success! render json: {id_token: token}"
			render json: {id_token: token}
		else # wrong password
			render json: {err: "Incorrect Password", cause: 'password'}, status: 401
		end
  end

	def myleague
		require 'yaml'
		user = current_user
		league = user.league
		players = YAML::load league.players
		players = players.values # [Player, Player, ...]
		# TODO: Set topbid to nil for other players, only owner should be able to see top bid of his own players
		users = league.users
		logs = Log.where(:action => ['transfer', 'sell', 'newplayer', 'joined', 'bid'], :league_id => [league.id, nil]).last(20)
		render json: {league: myleague_clean(league), users: league_users_clean(users, team_value(players)), players: players, playerdata: $playerdata, logs: logs.reverse, money: user.money, gameweek: $current_gameweek, transfersactive: $transfers_active} 
	end

	def all
		leagues = League.all
		leagues_json = []
		leagues.each do |league|
			users = league.users
			owner = league_owner(users, league.user_id)
			leagues_json.push({league: league, owner: owner ,users: league_users_clean(users), teams: users.length})
		end 
		render json: leagues_json
	end

  private

  def league_users_clean(users, teamvalue)
  	return users.map {|user| {id: user.id, name: user.name, team_name: user.team_name, money: user.money, totpoints: user.totpoints, gwpoints: user.gwpoints, teamvalue: teamvalue[user.id] || 0}}
  end

  def myleague_clean(league)
  	return {id: league.id, league_name: league.league_name}
  end

  def team_value(players) # sum up player value of each team
  	teamvalues = {}
  	players.each do |player|
  		if player.user_id
  			teamvalues[player.user_id] = (teamvalues[player.user_id] || 0) + player.value
  		end
  	end
  	return teamvalues
  end

  def league_owner(users, owner_id)
  	users.each {|user| return {name: user.name, email: user.email} if user.id == owner_id}
  	return {name: "Glenn", email: "glenn@hysen.se"}
  end

  def my_team(players, id)
  	players.keep_if {|player| player[:user] == id}
  	return players
  end

end

