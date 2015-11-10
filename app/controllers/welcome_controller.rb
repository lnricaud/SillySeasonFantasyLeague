class WelcomeController < ApplicationController
  def index
  	@user = current_user
  	if @user
  		if @user.league_id.nil?
	    	redirect_to "/leagues/new"
	    else
	    	redirect_to "/leagues/#{@user.id}"
	    end
  	else
  		render :index
  	end
  end
end
