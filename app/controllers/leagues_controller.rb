class LeaguesController < ApplicationController
	# before_action :authenticate

	def new
		p "IN LEAGUES NEW -----------"
		@user = current_user
		if @user.nil?
			redirect_to "/sign_in" 
		else
			@league = League.new
			@leagues = League.all
			
			render :new
		end
	end

	def create
		user = current_user
		p "--- in leagues#create ---"
		p "#{params}"
		p "user.email: #{user.email}"
		p "create league params: #{params}"
		p "current_user.id #{user.id}"
		# league_params = {:league_name => params["league"]["league_name"], :user_id => user.id, }
		league_params = params.permit(:league_name, :password)
		league_params[:user_id] = user.id
		p "CREATING A LEAGUE #{league_params}"
		league = League.create(league_params)
		p "League created? #{!league.nil?}, id: #{league.id}"
		if league.id.nil?
			p "ERROR! League not created!"
			# redirect_to "/leagues/new"
			render json: {error: "League not created: #{params}"}, status: :unprocessable_entity
		else
			updated_attributes = {:league_id => league.id}
			user.update_attributes(updated_attributes)
			p "user.league_id: #{user.league_id}"
			create_league_players(league.id)

			# redirect_to "/leagues/#{@user.id}"
			# Create new token that includes the 
			hmac_secret = '4eda0940f4b680eaa3573abedb9d34dc5f878d241335c4f9ef189fd0c874e078ad1a658f81853b69a6334b2109c3bc94852997c7380ccdebbe85d766947fde69'
			payload = {name: user.name, email: user.email, id: user.id, team_name: user.team_name, league_id: user.league_id}
			p "payload: #{payload}"
			token = JWT.encode payload, hmac_secret, 'HS256'

			p "Success! render json: {id_token: token}"
			render json: {id_token: token} 
		end
	end

	def createOld
		# @user = current_user
		p "--- in leagues#create ---"
		p "#{params}"
		p "@user"
		p "create league params: #{params}"
		p "params['league']['league_name'] #{params["league"]["league_name"]}"
		p "current_user.id #{@user.id}"
		league_params = {:league_name => params["league"]["league_name"], :user_id => @user.id}
		p "CREATING A LEAGUE #{league_params}"
		@league = League.create(league_params)
		p "League created? #{!@league.nil?}, #{@league.id}"
		if @league.id.nil?
			p "ERROR! League not created!"
			redirect_to "/leagues/new"
		else
			updated_attributes = {:league_id => @league.id}
			@user.update_attributes(updated_attributes)
			p "/leagues/#{@user.id}"
			create_league_players 
			redirect_to "/leagues/#{@user.id}"
		end
	end

	def view # preview of league to join
		p "in leagues#view, params: #{params}"
		id = params[:id]
		@league = League.find(id)
		@users = @league.users
		@admin = User.find(@league.user_id)
	end

  def join
  	p "join league params: #{params}"
  	# p "params['league']['league_name'] #{params["league"]["league_name"]}"
  	@user = current_user
  	p "@user.id #{@user.id}"
  	p "@league.id #{params["id"]}"
  	updated_attributes = {:league_id => params["id"]}
  	@user.update_attributes(updated_attributes)
		redirect_to "/leagues/#{params["id"]}" 
  end

	def show
		@user = current_user
		if @user.league_id.nil?
			redirect_to "/leagues/new"
		else
			@league = @user.league
			@users = @league.users
			@names = @users.map {|name| (name.team_name unless name.team_name.nil?) }
			p "names: #{@names}"
			p "Team name: #{@user.team_name}"
			if @user.team_name.nil?
				redirect_to "/teams/index"
			else
				render :show
			end
		end
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
  def create_league_players(id)
  	1.upto(Playerdata.count) do |i|
  		Player.create({league_id: id, playerdata_id: i, value: 4000000})
  	end
  end

  def league_users_clean(users)
  	clean_users = []
  	users.each {|user| clean_users.push({id: user.id, name: user.name, email: user.email, team_name: user.team_name, money: user.money, totpoints: user.totpoints, gwpoints: user.gwpoints, playervalue: player_value(user.players)})}
  	return clean_users
  end

  def player_value(players)
  	return players.inject(0) { |value, player| value + player.value }
  end

  def league_owner(users, owner_id)
  	users.each {|user| return {name: user.name, email: user.email} if user.id == owner_id}
  	return {name: "Glenn", email: "glenn@hysen.se"}
  end

end

