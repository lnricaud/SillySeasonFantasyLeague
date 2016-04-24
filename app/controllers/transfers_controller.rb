class TransfersController < ApplicationController
	before_action :authenticate

	def stoptransfers
		user = current_user
		# if !$transfers_active
		# 	render json: {err: 'Transfers already Stopped'}, status: 422
		if user.admin
			p "in stop transfers"
			subtract_salaries_and_set_owned_true
			log = Log.create(action: "stoptransfers", game_week: $current_gameweek, user_id: user.id)
			render json: {response: 'Transfers Stopped'}
		else
			render json: {err: 'Not Autherized to Stop Transfers'}, status: 401
		end
	end

	def newgameweek # changes to next gameweek and transfers becomes active
		# check if user is admin
		user = current_user
		if user.admin
			if $transfers_active
				subtract_salaries_and_set_owned_true
			end
			p "<=><=><=><=><=><=> in newgameweek before calc_points"
			calc_points
			p "<=><=><=><=><=><=> in newgameweek after calc_points"
			$current_gameweek += $current_gameweek
			Log.create(action: 'newgameweek', game_week: $current_gameweek, user_id: user.id)
			$transfers_active = true
			render json: {response: 'New Game Week', gameweek: $current_gameweek}
		else
			render json: {err: 'Not Autherized to Start New GameWeek'}, status: 401
		end 
	end

	def bid
		require 'yaml'
		bid = params[:bid].to_i
		user = current_user
		league = user.league
		sentPlayer = params[:player]
		players = YAML::load league.players
		player = players[sentPlayer["id"]]
# Player changed on server
		unless player.value == sentPlayer[:value] && player.user_id == sentPlayer[:user_id] && player.owned == sentPlayer[:owned]
			render json: {err: "Player has changed on the server"}, status: 422
		else
			playername = $playerdata[player.id].web_name
# Player owned by bidder, just updating the topbid
			if user.id == player.user_id 
				player.topbid = bid
			else
# Player is a free agent, not owned by anyone
				if player.user_id.nil?
					fee = user.money - player.value
					user.update_attributes(money: fee) # subtracts the value of the player from user's money
					player.topbid = bid
				  player.user_id = user.id
					logmessage = "#{user.team_name} bought #{playername} for #{currency(player.value)}"
				else
# Bid is higher than topbid
					owner = User.find_by_id player.user_id
					if bid > player.topbid
						value = (bid < (player.topbid + 100000) ? bid : (player.topbid + 100000))
						player.topbid = bid
						fee = user.money - player.value
						user.update_attributes(money: fee) # user pays for the player
						if player.owned # owner makes a profit
							profit = owner.money + value # get's the updated value
							owner.update_attributes(money: profit)
						else # owner get his money back, no profit
							refund = owner.money + player.value # get's back what he payed
							owner.update_attributes(money: refund)
						end
						player.value = value
						player.user_id = user.id
						player.owned = false
						logmessage = "#{user.team_name} successfully bought #{playername} from #{owner.team_name} for #{currency(player.value)}"
					else
# bid increases value of player for current owner
						unless player.owned
							value_increase = owner.money - (bid - player.value)
							owner.update_attributes(money: value_increase)
						end							
						player.value = bid
						logmessage = "#{user.team_name} unsuccessfully bid #{currency(bid)} on #{playername} from #{owner.team_name}"
					end
					player.salary
					player.sellvalue
				end
				Log.create(action: "bid", game_week: $current_gameweek, user_id: user.id, player_id: player.id, league_id: user.league_id, value: player.value, message: logmessage)
			end
			serialized_players = YAML::dump players
			league.update_attributes(players: serialized_players)
			render json: {updatedPlayer: player} # TODO: send 20 last logs/for now only update logs when visiting logs tab in view
		end
	end

	def sell
		require 'yaml'
		p "-- In transfers#sell params: #{params}"
		sell_id = params[:id].to_i
		user = current_user
		league = user.league
		players = YAML::load league.players
		player = players[sell_id]
		if player.user_id == user.id
			# if player was owned refund sellvalue
			if player.owned
				value = player.sell
				user.update_attributes(money: user.money + value)
				sellmessage = "#{user.team_name} sold #{$playerdata[sell_id].web_name} for #{currency(value)}"
			else # else subtract 10% of player value
				loss = (player.sell / 9).round
				user.update_attributes(money: user.money - loss)
				sellmessage = "#{user.team_name} sold #{$playerdata[sell_id].web_name} for #{currency(player.value)} and made a loss of #{currency(loss)}"
			end
			Log.create(action: "sell", game_week: $current_gameweek, user_id: user.id, player_id: player.id, league_id: league.id, value: value, message: sellmessage)
			serialized_players = YAML::dump players
			league.update_attributes(players: serialized_players)
			render json: {response: 'player sold', money: user.money, updatedPlayer: player}
		else # player has been bought by someone already or couldn't be found
			render json: {err: 'Player was no longer yours', updatedPlayer: player}, :status => 422
		end
	end

	private
	def calc_points
		require 'yaml'
		leagues = League.all
		leagues.each do |league|
			players = YAML::load league.players
			users = league.users
			points = {"Goalkeeper" => {}, "Defender" => {}, "Midfielder" => {}, "Forward" => {}}
			players.each do |id, player| 
				if player.user_id
					if points[$playerdata[id].position][player.user_id].nil?
						points[$playerdata[id].position][player.user_id] = [$playerdata[id].gw_points]
					else
						points[$playerdata[id].position][player.user_id].push($playerdata[id].gw_points)		
					end
				end
			end
			users.each do |user| # add up points
				arr = points["Goalkeeper"][user.id] || [0]
				gw_team_points = arr.max
				arr = points["Defender"][user.id] || [0]
				gw_team_points += (arr.size > 3 ? arr.sort[-3,3].inject(:+) : arr.inject(:+))
				arr = points["Defender"][user.id] || [0]
				gw_team_points += (arr.size > 4 ? arr.sort[-4,4].inject(:+) : arr.inject(:+))
				arr = points["Forward"][user.id] || [0]
				gw_team_points += (arr.size > 3 ? arr.sort[-3,3].inject(:+) : arr.inject(:+))
				p "user: #{user.name} got #{gw_team_points} points and #{currency(gw_team_points * 1000000)}"
				totpoints = user.totpoints + gw_team_points
				earnings = user.money + (gw_team_points * 1000000)
				user.update_attributes(gwpoints: gw_team_points, totpoints: totpoints, money: earnings)
			end
		end

	end

	def subtract_salaries_and_set_owned_true
		require 'yaml'
		$transfers_active = false
		leagues = League.all
		leagues.each do |league|
			players = YAML::load league.players
			users = league.users
			salaries = {}
			players.each do |id, player|
				if player.owned
					salaries[player.user_id] = (salaries[player.user_id] || 0) + player.salary
				end
			end
			users.each {|user| unless salaries[user.id].nil? then user.update_attributes(money: user.money - salaries[user.id]) end}
			players.map do |id, player| # update owned players and gw_value
				player.owned = (player.user_id ? true : false)
				# maybe decrease value for un-owned players as well
				player.gw_value = player.value
			end
			serialized_players = YAML::dump players
			league.update_attributes(players: serialized_players)
		end
	end

	private

	def currency(value)
		str = value.to_s
		currency = ""
		while str.length > 3
			currency = ",#{str[-3,3]}#{currency}"
			str = str[0...-3]
		end
		return "£#{str}#{currency}"
	end

end
