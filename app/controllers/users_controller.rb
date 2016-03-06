require 'jwt'

class UsersController < ApplicationController
	# def index
	# 	@users = User.all
	# 	render :index
	# end
 	$users = [{
	  id: 1,
	  username: 'gonto',
	  password: 'gonto'
	}];

	def jwtcreate
		p "jwtcreate: #{params}"
		user_params = {name: params["username"], password: params["password"]}
		p "CREATING A jwt USER #{user_params}"

		# app.post('/users', function(req, res) {
		  
	  userScheme = getUserScheme(user_params)
	  p "userScheme #{userScheme}"

	  if (!userScheme[:username] || !user_params[:password])
	  	p "You must send the username and the password"
	    render json: "You must send the username and the password"
	  end
	  profile = {username: userScheme[:username], password: user_params[:password]}
	  profile[:id] = $users.length + 1
	  $users.push(profile);
	  p "users: #{$users}"
	  hmac_secret = '4eda0940f4b680eaa3573abedb9d34dc5f878d241335c4f9ef189fd0c874e078ad1a658f81853b69a6334b2109c3bc94852997c7380ccdebbe85d766947fde69'
	  payload = {name: profile[:username], id: profile[:id]}
	  token = JWT.encode payload, hmac_secret, 'HS256'

	  # eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0ZXN0IjoiZGF0YSJ9._sLPAGP-IXgho8BkMGQ86N2mah7vDyn0L5hOR4UkfoI
	  p "=== token: #{token}"

	  decoded_token = JWT.decode token, hmac_secret, true, { :algorithm => 'HS256' }

	  # Array
	  # [
	  #   {"data"=>"test"}, # payload
	  #   {"typ"=>"JWT", "alg"=>"HS256"} # header
	  # ]
	  p "=== decoded_token: #{decoded_token}"
	  # if (_.find(users, userScheme.userSearch)) {
	  #  return res.status(400).send("A user with that username already exists");
	  # }

	  # var profile = _.pick(req.body, userScheme.type, 'password', 'extra');
	  # profile.id = _.max(users, 'id').id + 1;

	#   users.push(profile);

		render json: {id_token: token}
	end

	def create
		user_params = params.permit(:name, :email, :league_id, :password)
		p "CREATING A USER #{user_params}"

		@user = User.create(user_params)
		p "User created? #{!@user.nil?}, #{@user.id}"
		if @user.id.nil?
			p "ERROR! User not created!"
			render json: "Error! User not create!"
		else
			# login(@user) # this is taken care of by jwt
		  # SignupMailer.signup_mail(@user).deliver_now!
			hmac_secret = '4eda0940f4b680eaa3573abedb9d34dc5f878d241335c4f9ef189fd0c874e078ad1a658f81853b69a6334b2109c3bc94852997c7380ccdebbe85d766947fde69'
			payload = {name: @user.name, email: @user.email, id: @user.id}
			token = JWT.encode payload, hmac_secret, 'HS256'

			p "Success! render json: {id_token: token}"
			render json: {id_token: token} 
		end
	end

	def create_Old
		user_params = params.require(:user).permit(:name, :email, :league_id, :password)
		p "CREATING A USER #{user_params}"
		@user = User.create(user_params)
		p "User created? #{!@user.nil?}, #{@user.id}"
		if @user.id.nil?
			p "ERROR! User not created!"
			redirect_to "/users/new"
		else
			login(@user)
		  SignupMailer.signup_mail(@user).deliver_now!
			p "Redirecting #{@user.name} to leagues page"
			redirect_to "/leagues/new" 
		end
	end

	def new
		p "IN USERS NEW -----------"
		@user = User.new
		render :new
	end

	def show
		id = params[:id]
		@user = User.find(id)
		@current_user = current_user
		render :show
	end

	def quicklogin # to be used for testing
		p "in user#quicklogin, params[:email]: #{params[:email]}"
		# logout current user
		destroy # sessions_helper function
		email = "#{params[:email]}@test.com"
		# check if user exists
		@user = User.find_by email: email
		if @user.nil? # create
			u_params = {email: email, password: "qwe"}
			case email
			when "kl@test.com"
				u_params[:name] = "Kristian"
				u_params[:team_name] = "IFK Göteborg"
			when "pn@test.com"
				u_params[:name] = "Patrik"
				u_params[:team_name] = "Arsenal"
			when "jl@test.com"
				u_params[:name] = "Johan"
				u_params[:team_name] = "Liverpool"
			else
				u_params[:name] = "Peter"
				u_params[:team_name] = "ManU"
			end
			p "Creating quicklogin user: #{u_params}"
			@user = User.create(u_params)
		end
		# login
		login(@user)
		redirect_to "/leagues/#{@user.id}"
	end

	# def edit
	# 	id = params[:id]
	# 	@user = User.find(id)
	# 	render :edit
	# end

	# def update
	# 	user_id = params[:id]
	# 	user = User.find(user_id)

	# 	# get updated data
	# 	updated_attributes = params.require(:user).permit(:name, :_id)
	# 	# update the user
	# 	user.update_attributes(updated_attributes)

	# 	#redirect to show
	# 	redirect_to "/teams/#{user.id}"  # <-- go to show
	# end


	private
	def getUserScheme(user)
	  # The POST contains a username and not an email
	  if (user[:name])
	    username = user[:name]
	    type = 'username'
	    userSearch = { username: username }
	  
	  # The POST contains an email and not an username
	  elsif (user[:email])
	    username = user[:email]
	    type = 'email'
	    userSearch = { email: username }
	  end

	  return {
	    username: username || nil,
	    type: type || nil,
	    userSearch: userSearch || nil
	  }
	end


end
