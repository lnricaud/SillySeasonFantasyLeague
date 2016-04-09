class WelcomeController < ApplicationController

  def index
    # render welcome view here, view should have Proceed to App button and admin controlls
    render :index
  end

end
      # if @user.league_id.nil?
        # redirect_to "/leagues/#{@user.id}"
