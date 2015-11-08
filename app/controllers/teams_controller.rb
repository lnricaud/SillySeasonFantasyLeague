class TeamsController < ApplicationController
	def index
		@user = current_user
		render :name 
	end

	def name
		p "params in name: #{params}"
		updated_attributes = {:team_name => params["team_name"]}
		@user = current_user
		@user.update_attributes(updated_attributes)
		redirect_to "/leagues/#{@user.id}" 
	end

end
