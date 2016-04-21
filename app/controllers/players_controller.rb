class PlayersController < ApplicationController
	before_action :authenticate
	
	def refresh
		require 'json'
		require 'yaml' # preserves class properties and methods
		require 'open-uri'
		require 'player'

		user = current_user
		if user.admin
			
			playersadded = false # do not update league.players unless new players has been added
			$leagueplayers = Hash.new # resets the global variable so that will contain updated data
			league_players = Hash.new # league_players[league_id] = {id: Player, id: Player, ...} <- League.players
			leagues = League.all
			unless leagues.nil?
				leagues.each { |league| league_players[league.id] = YAML::load league.players }
			end
			db_player_data = Playerdata.last
			if db_player_data.nil?
				newplayer = false # don't create new player log for start of season
				$playerdata = Hash.new
			else
				newplayer = true
				$playerdata = YAML::load db_player_data.data
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
						league_players.map {|league_id, players| players[i] = Player.new(i)}
					end
					if newplayer # only create log if not start of season
					Log.create(action: "newplayer", game_week: $current_gameweek, player_id: i, message: "#{player_data["web_name"]} added to #{player_data["team_name"]}")
					end
				end
				# add player to $playerdata hash
				$playerdata[i] = Playerstats.new(player_data)
				p "Got api data: #{i}"
				i += 1
			end
			
			# Add playerdata to playerdata.data
			serialized_playerdata = YAML::dump($playerdata)
			Playerdata.create(data: serialized_playerdata)
			if playersadded && !leagues.nil? # update players in each league
				leagues.each {|league| league.update_attributes(players: YAML::dump(league_players[league.id]))}
			end
			render json: {response: 'Player Data Refreshed'}
		else
			render json: {err: 'Not Autherized to Refresh Player Data'}, status: 401
		end
	end

end
