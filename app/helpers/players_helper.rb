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

	def leagueplayers(league)
		parsedata unless defined? $data
		$leagues = Hash.new unless defined? $leagues
		if !$leagues.key?('league.id')
			players = Array.new
			league_players = league.players
			league_players.each do |player|
				playerhash = {				
					id: player.playerdata_id,
					user: player.user_id,
					value: player.value,
					owned: player.owned,
					topbid: player.topbid,
					data: $data[player.id]
				}
				players.push(playerhash.merge($data[player.id]))
				$leagues[league.id] = players
			end
		end
		return $leagues[league.id]
	end
	
	def getplayerpoints
		gw = current_gameweek
		# get gw points for all players
		owned_players = Player.where(owned: true)
		points = Hash.new
		gwpoints = owned_players.each_with_object(Hash.new(0)) { |player, counts| counts[player.user_id] += $data[player.id][:fixtures_played][gw - 1][19] }
		# loop through gw points, create log for gw points for each user. Increase money for each user. 
		p "GW: #{gw}, Points: #{gwpoints}"
		users = User.all
		gwpoints.each do |user_id, points|
			user = users.find_by_id user_id
			Log.create(action: 'gwpoints', game_week: gw, user_id: user_id, league_id: user.league_id, value: points)
			money = user.money + points * 1000000
			totpoints = user.totpoints + points
			user.update_attributes(money: money, gwpoints: points, totpoints: totpoints)
		end
	end
end
