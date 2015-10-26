class TeamsController < ApplicationController
	def show
		id = params[:id]
		@user = User.find(id)
		@current_user = current_user
		render :show
	end
end
