class TeamsController < ApplicationController
	def show
		@leagues = League.all unless defined? @leagues
		id = params[:id]
		@user = User.find(id)
		# @current_user = current_user
		@league = League.new if @user.league_id.nil?
		render :show
	end
end
