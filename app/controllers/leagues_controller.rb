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
			# login(@league)
			user_league_id
			p "/teams/#{@user.id}"
			redirect_to "/teams/#{@user.id}" 
		end
	end
	def show
		id = params[:id]
		@league = League.find(id)
		@users = @league.users
		@admin = User.find(@league.user_id)
	end
  # def update
  #   user_id = params[:id]
  #   p "params: #{params}, user_id: #{user_id}"
  #   user = User.find(user_id)

  #   # get updated data
  #   updated_attributes = params.require(:user).permit(:league_id)
  #   # update the user
  #   user.update_attributes(updated_attributes)

  #   #redirect to show
  #   redirect_to "/teams/#{user.id}"
  # end
  def join
  	p "join league params: #{params}"

  	# p "params['league']['league_name'] #{params["league"]["league_name"]}"
  	@user = current_user
  	p "@user.id #{@user.id}"
  	p "@league.id #{params["id"]}"
  	updated_attributes = {:league_id => params["id"]}
  	@user.update_attributes(updated_attributes)
		redirect_to "/teams/#{@user.id}" 
  end
	
	private
	def user_league_id
		p "updating users league_id ..."
		p "@user #{@user.name}"
		p "@league #{@league.league_name}"
		updated_attributes = {:league_id => @league.id}
		@user.update_attributes(updated_attributes)
		p "@user after league_id update: #{@user}"
	end

end

