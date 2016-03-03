class SessionsController < ApplicationController

	def new
	  @user = User.new
	  render :new
	end

	def oldcreate
	  user_params = params.require(:user).permit(:email, :password)
	  @user = User.confirm(user_params)
	  p "IN SESSIONS/CREATE =============================================="
	  render json: "Managed to get sessions#create: #{params}"
	  if @user
	    login(@user)
	    if @user.league_id.nil?
	    	redirect_to "/leagues/new"
	    else
	    	redirect_to "/leagues/#{@user.id}"
	    end
	  else
	    redirect_to "/sign_in"
	  end
	end

	def destroy
	  # logout
	  session[:user_id] = nil
	  redirect_to "/sign_in"
	end

	# JWT functions
	def random_quote
		render json: "IT's Working!!!"
	end

	def protected
		p "Protected: , #{params}"
	end

	def create
		hmac_secret = 'ngEurope rocks!'
		payload = {name: "Kristian", id: 3}
		token = JWT.encode payload, hmac_secret, 'HS256'
		render json: {id_token: token}
	end

end
