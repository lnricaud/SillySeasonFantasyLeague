class UsersController < ApplicationController
	# def index
	# 	@users = User.all
	# 	render :index
	# end

	def new
		p "IN USERS NEW -----------"
		@user = User.new
		render :new
	end

	def create
		user_params = params.require(:user).permit(:name, :email, :league_id, :password)
		p "CREATING A USER #{user_params}"
		@user = User.create(user_params)
		p "User created? #{!@user.nil?}, #{@user.id}"
		if @user.id.nil?
			p "ERROR! User not created!"
			redirect_to "/users/new"
		else
			login(@user)
# ------------------------
	    # @booking.passengers.each { |p| PassengerMailer.thank_you_email(p).deliver! }
		  SignupMailer.signup_mail(@user).deliver_now!
# ------------------------
			p "Redirecting #{@user.name} to leagues page"
			redirect_to "/leagues/new" 
		end
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



end
