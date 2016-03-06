class SessionsController < ApplicationController

	def new
	  @user = User.new
	  render :new
	end

	def create
	  user_params = params.require(:session).permit(:email, :password)
	  p "Trying to login =============================="
	  p "params: #{params}"
	  p "user_params: #{user_params}"
	  @user = User.confirm(user_params)
	  p "IN SESSIONS/CREATE =============================================="
	  if @user
	  	hmac_secret = '4eda0940f4b680eaa3573abedb9d34dc5f878d241335c4f9ef189fd0c874e078ad1a658f81853b69a6334b2109c3bc94852997c7380ccdebbe85d766947fde69'
	  	payload = {name: @user.name, email: @user.email, id: @user.id, league_id: @user.league_id}
	  	token = JWT.encode payload, hmac_secret, 'HS256'

	  	p "Success! render json: {id_token: token}"
	  	render json: {id_token: token} 
	    # login(@user)
	    # if @user.league_id.nil?
	    # 	render json: "Join a league"
	    # else
	    # 	render json: "Send redirect to league"
	    # end
	  else
	    render json: "Email and password doesn't match"
	  end
	end

	def createNewNotUsed
		hmac_secret = '4eda0940f4b680eaa3573abedb9d34dc5f878d241335c4f9ef189fd0c874e078ad1a658f81853b69a6334b2109c3bc94852997c7380ccdebbe85d766947fde69'
		payload = {name: "Kristian", id: 3}
		token = JWT.encode payload, hmac_secret, 'HS256'
		render json: {id_token: token}
	end

	def destroy
	  # logout
	  session[:user_id] = nil
	  redirect_to "/sign_in"
	end

	# JWT functions
	def random_quote

		render json: params
	end

	def protected
    if current_user
      # head :ok
      p "current_user: #{current_user}"
      render json: "Hello!!!"
    else
    	# send to sign in
      head :not_found
    end
	end



end
