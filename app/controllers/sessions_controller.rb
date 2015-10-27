class SessionsController < ApplicationController

	def new
	  @user = User.new
	  render :new
	end

	def create
	  user_params = params.require(:user).permit(:email, :password)
	  @user = User.confirm(user_params)
	  if @user
	    login(@user)
	    if @user.league_id.nil?
	    	redirect_to "/leagues/new"
	    else
	    	redirect_to "/teams/#{@user.id}"
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

end
