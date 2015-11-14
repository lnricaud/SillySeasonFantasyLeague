class LeaguesController < ApplicationController
	
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
		@user = current_user
		p @user
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

  private
  def create_league_players
  	1.upto(Playerdata.count) do |i|
  		Player.create({league_id: @league.id, playerdata_id: i, value: 100000000})
  	end
  end
end

