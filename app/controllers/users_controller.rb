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
		user_params[:money] = 100000000
		p "CREATING A USER #{user_params}"
		@user = User.create(user_params)
		p "User created? #{!@user.nil?}, #{@user.id}"
		if @user.id.nil?
			p "ERROR! User not created!"
			redirect_to "/users/new"
		else
			login(@user)
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
