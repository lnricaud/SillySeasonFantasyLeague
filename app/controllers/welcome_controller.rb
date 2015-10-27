class WelcomeController < ApplicationController
  def index
  	@user = current_user
  	if @user
  		if @user.league_id.nil?
	    	redirect_to "/leagues/new"
	    else
	    	redirect_to "/teams/#{@user.id}"
	    end
  	else
  		render :index
  	end
  end
end
