class WelcomeController < ApplicationController

  def index
    @user = current_user
    if @user
      render json: {isSignedIn: true, user: @user.name}
    else
      render json: {isSignedIn: false}
    end
  end

end
      # if @user.league_id.nil?
        # redirect_to "/leagues/#{@user.id}"
