class PlayersController < ApplicationController
	before_action :authenticate
	
	def refresh
		require 'json'
		require 'open-uri'
		require 'player_data'
		require 'player'

		user = current_user
		if user.admin
			
			gw = current_gameweek + 1 # new players available next game week
			playersadded = false # do not update league.players unless new players has been added
			league_players = Hash.new
		 #league_players[league_id] = [Player, Player, ...] <- League.players
			leagues = League.all
			leagues.each { |league| league_players[league.id] = JSON.parse league.players } unless leagues.nil?
			db_player_data = Playerdata.last
			if db_player_data.nil?
				newplayer = false # don't create new player log for start of season
				$Playerdata = Hash.new
			else
				newplayer = true
				$Playerdata = JSON.parse db_player_data.data
			end

			i = 1
			loop do
				begin
				  player_data = JSON.parse open("http://fantasy.premierleague.com/web/api/elements/#{i}/").read  
				rescue OpenURI::HTTPError   
				  p "Found last element, breaking out of loop"
				  break  
				end  

				if $playerdata[i].nil? # Add player class to each league
					unless league_players.empty?
						playersadded = true # update league.players
						league_players.map {|league_id, players| players.push Player(i)}
					end

					if newplayer # only create log if not start of season
					Log.create(action: "newPlayer", game_week: gw, player_id: i, message: "#{player_data["web_name"]} added to #{player_data["team_name"]}")
					end
				end
				
				# add player to $playerdata hash
				$playerdata[i] = playerdata.new(player_data)

				i += 1
			end
			p "%%%%%%%%%%%%%%%%%%%%% $playerdata: #{$playerdata}"
			# Add playerdata to playerdata.data
			Playerdata.create(data: $playerdata.to_json)
			if playersadded # update players in each league
				leagues.each {|league| league.update_attributes(players: league_players[league.id].to_json)}
			end
			# byebug
			# parsedata
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
