class SessionsController < ApplicationController

	def create
	  user_params = params.require(:session).permit(:email, :password)
	  p "Trying to login =============================="
	  p "params: #{params}"
	  p "user_params: #{user_params}"
	  user = User.confirm(user_params)
	  p "IN SESSIONS/CREATE =============================================="
	  if user
	  	hmac_secret = '4eda0940f4b680eaa3573abedb9d34dc5f878d241335c4f9ef189fd0c874e078ad1a658f81853b69a6334b2109c3bc94852997c7380ccdebbe85d766947fde69'
	  	payload = {name: user.name, email: user.email, id: user.id, team_name: user.team_name, league_id: user.league_id, admin: user.admin}
	  	token = JWT.encode payload, hmac_secret, 'HS256'

	  	p "Success! render json: {id_token: token}"
	  	render json: {id_token: token} 
	    # login(user)
	    # if user.league_id.nil?
	    # 	render json: "Join a league"
	    # else
	    # 	render json: "Send redirect to league"
	    # end
	  else
	  	user = User.find_by email: user_params[:email]
	  	p "Trying to find user by email: #{user_params[:email]}"
	  	p "Did we find him? #{user}"
	  	if user
	    	render json: {err: "Email and password doesn't match", cause: 'password'}, status: 401
	    else
	  		render json: {err: "User cannot be found", cause: 'email'}, status: 401
	  	end
	  end
	end

	def destroy
	  # logout
	  session[:user_id] = nil
	  redirect_to "/sign_in"
	end




end
