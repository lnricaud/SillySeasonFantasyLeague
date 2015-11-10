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

	def show
		p "In teams#show, params: #{params}"
		p "Team ID: #{params[:team]}"
		@manager = User.find_by_id(params[:team])
		@players = @manager.players # connect data to players
		@data = Playerdata.all # make global and update in players#refresh
		# @players.map {|player| player[:data] = @data[]}
		# @playerData = @players.each {|player| }
		render :show
	end

end
