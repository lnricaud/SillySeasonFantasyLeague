require 'jwt'

class UsersController < ApplicationController

	def create
		p "user#create, params: #{params}"
		user_params = params.permit(:name, :team_name, :email, :password)
		user_params[:email] = user_params[:email].downcase
		p "CREATING A USER #{user_params}"
		@user = User.create(user_params)
		p "User created? #{!@user.id.nil?}, #{@user.id}"
		if @user.id.nil?
			p "ERROR! User not created!"
			render json: { error: 'User not created' }, status: :unauthorized
		else
		  # SignupMailer.signup_mail(@user).deliver_now!

			hmac_secret = '4eda0940f4b680eaa3573abedb9d34dc5f878d241335c4f9ef189fd0c874e078ad1a658f81853b69a6334b2109c3bc94852997c7380ccdebbe85d766947fde69'
			payload = {id: @user.id, name: @user.name, email: @user.email, team_name: @user.team_name, league_id: nil}
			p "payload: #{payload}"
			token = JWT.encode payload, hmac_secret, 'HS256'

			p "Success! render json: {id_token: token}"
			render json: {id_token: token} 
		end
	end

end
