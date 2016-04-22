module PlayersHelper
	
	# def playerdata
	# 	p "in playerdata"
	# 	require 'json'
	#   db_player_data = Playerdata.last
 #    if db_player_data.nil?
 #      $playerdata = Hash.new
 #    else
 #      $playerdata = JSON.parse db_player_data.data
 #    end
	# end

	# def leagueplayers(league)
	# 	# parsedata unless defined? $data
	# 	# $leagues = Hash.new unless defined? $leagues
	# 	# if !$leagues.key?('league.id')
	# 		players = Array.new
	# 		# league_players = league.players
	# 		league_players = JSON.parse league.players
	# 		p "<>>>>>>><<<<<<<>>>>>><<<<<><>>>>>><<>>"
	# 		p league_players.first
	# 		league_players.each do |player|
	# 			playerhash = {				
	# 				id: player.id,
	# 				playerdata_id: player.playerdata_id,
	# 				user: player.user_id,
	# 				user_name: nil,
	# 				value: player.value,
	# 				owned: player.owned,
	# 				topbid: player.topbid,
	# 			}
	# 			players.push(playerhash.merge($playerdata[player.playerdata_id]))
	# 		# $leagues[league.id] = players
	# 		end
	# 	# end
	# 	# return $leagues[league.id]
	# 	return players
	# end
	
	def getplayerpoints
		# gw = current_gameweek
		# get gw points for all players
		owned_players = Player.where(owned: true)
		points = Hash.new
		gwpoints = owned_players.each_with_object(Hash.new(0)) { |player, counts| counts[player.user_id] += $data[player.id][:fixtures_played][$current_gameweek - 1][19] }
		# loop through gw points, create log for gw points for each user. Increase money for each user. 
		p "GW: #{gw}, Points: #{gwpoints}"
		users = User.all
		gwpoints.each do |user_id, points|
			user = users.find_by_id user_id
			Log.create(action: 'gwpoints', game_week: $current_gameweek, user_id: user_id, league_id: user.league_id, value: points)
			money = user.money + points * 1000000
			totpoints = user.totpoints + points
			user.update_attributes(money: money, gwpoints: points, totpoints: totpoints)
		end
	end
end
