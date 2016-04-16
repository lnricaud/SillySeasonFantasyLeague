class PlayersController < ApplicationController
	before_action :authenticate
	require_relative 
	def refresh
		user = current_user
		if user.admin
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
				# p player_data["id"]
				db_data = Playerdata.find_by_id(i)
				if db_data.nil?
					p "Creating new Playerdata"
					# update Playerdata to hold all columns instead of json
					player = Playerdata.create(data: player_data)
					p "Adding new Player to all Leagues"
					Log.create(action: "newPlayer", game_week: current_gameweek, player_id: i, message: "Player added to league")
					leagueplayers
					1.upto(League.count) do |l|
						# refactor to add player json to League.players instead


						pl = Player.create({league_id: l, playerdata_id: i, value: 4000000})
						p "Created player: #{pl[:id]}"
					end
				else
					p "Uppdating existing playerdata.data"
					updated_attributes = {:data => player_data}
					db_data.update_attributes(updated_attributes)
				end
				i += 1
			end
			# byebug
			parsedata
			render json: {response: 'Player Data Refreshed'}
		else
			render json: {err: 'Not Autherized to Refresh Player Data'}, status: 401
		end
	end

	# def players
	# 	user = current_user
	# 	players = Player.where(league_id: user.league_id)
	#  	player_data = parsedata unless defined? $data # update view later to accept @data instead of @player_data, also change so the it uses keys instead of json
	# 	# byebug
	# 	render :players
	# end
	# def player # show player data
	# 	p "Showing player, params: #{params}"
	# 	@player = Player.find_by_id(params[:id])
	# 	p @player
	# 	@player_data = JSON.parse(@player.playerdata.data)
	# 	p @player_data
	# 	render :player
	# end


end
