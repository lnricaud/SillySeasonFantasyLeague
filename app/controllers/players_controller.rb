class PlayersController < ApplicationController
	def refresh
		require 'open-uri'
		require 'json'
		i = 1
		loop do
			begin
			  player_data = open("http://fantasy.premierleague.com/web/api/elements/#{i}/").read  
			rescue OpenURI::HTTPError   
			  p "Found last element, breaking out of loop"
			  break  
			end  
			p player_data["id"]
			db_data = Playerdata.find_by_id(i)
			if db_data.nil?
				p "Creating new Playerdata"
				Playerdata.create(data: player_data)
				p "Adding new Player to all Leagues"
				Log.create(action: "newPlayer", game_week: current_gameweek, player_id: i)
				1.upto(League.count) do |l|
					pl = Player.create({league_id: l, playerdata_id: i, value: 100000000})
					p "Created player: #{pl}"
				end
			else
				p "Uppdating existing playerdata.data"
				updated_attributes = {:data => player_data}
				db_data.update_attributes(updated_attributes)
			end
			i += 1
		end
		# byebug
		redirect_to "/" 
	end
	def players
		@user = current_user
		@players = Player.where(league_id: @user.league_id)
		@playerdata = Playerdata.all unless defined? @playerdata
	 	@player_data = @playerdata.map {|player| JSON.parse(player.data)}
		# byebug
		render :players
	end
	def player # show player data
		p "Showing player, params: #{params}"
		@player = Player.find_by_id(params[:id])
		p @player
		@player_data = JSON.parse(@player.playerdata.data)
		p @player_data
		render :player
	end


end
