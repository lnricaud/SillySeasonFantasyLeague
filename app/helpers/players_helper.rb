module PlayersHelper
	def parsedata
		playerdata = Playerdata.all
		$data = Hash.new
		data = playerdata.map {|player| JSON.parse(player.data)}
		data.each do |player| 
			$data[player["id"]] = {
				# api data
				web_name: player["web_name"],
				first_name: player["first_name"],
				last_name: player["second_name"],
				team_name: player["team_name"],
				position: player["type_name"],
				team_id: player["team_id"],
				current_fixture: player["current_fixture"],
				next_fixture: player["next_fixture"],
				news: player["news"],
				fixtures_played: player["fixture_history"]["all"],
				fixtures_last3: player["fixture_history"]["summary"],
				fixtures_next: player["fixtures"]["all"],
				fixtures_next3: player["fixtures"]["summary"],
				# gameweek stats
				gw_points: player["event_total"],
				gw_details: player["event_explain"],
				gw_plays: player["chance_of_playing_this_round"],
				gw_plays_next: player["chance_of_playing_next_round"],
				gw_details: player["event_explain"], # dynamic array
				# season stats
				total_points: player["total_points"],
				minutes: player["minutes"],
				points_per_game: player["points_per_game"],
				goals_scored: player["goals_scored"],
				assists: player["assists"],
				clean_sheets: player["clean_sheets"],
				goals_conceded: player["goals_conceded"],
				own_goals: player["own_goals"],
				penalties_saved: player["penalties_saved"],
				penalties_missed: player["penalties_missed"],
				yellow_cards: player["yellow_cards"],
				red_cards: player["red_cards"],
				saves: player["saves"],
				bonus: player["bonus"],
				season_history: player["season_history"] # array
				# some data not included here from the official api data
			}
		end
	end

	def mergeplayerdata
		$leagues = Hash.new unless defined? $leagues
		players = Hash.new
		league_players = @league.players
		league_players.each do |player|
			# this is stupid, adding the same data to all players. Refactor later on
			players[player.id] = $data[player.id]
			players[player.id][:league] = player.league_id
			players[player.id][:user] = player.user_id
			players[player.id][:value] = player.value
			players[player.id][:owned] = player.owned
			players[player.id][:topbid] = player.topbid
			$leagues[@league.id] = players
		end
	end
	
	def getplayerpoints
		gw = current_gameweek
		# get gw points for all players
# bug, $data is at this point not correct, it contains league specific data and fixtures_played is nil
		byebug
		# $data.each {|player| }

	end
end
