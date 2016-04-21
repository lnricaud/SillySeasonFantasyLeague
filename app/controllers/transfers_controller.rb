class TransfersController < ApplicationController
	before_action :authenticate

	# def index
	# 	require 'json'
	# 	@user = current_user
	# 	@league = @user.league
	# 	@userclean = {id: @user.id, name: @user.name, team_name: @user.team_name, league_id: @user.league_id, league_name: @league.league_name, money: @user.money, gwpoints: @user.gwpoints, totpoints: @user.totpoints}
	# 	@users = @league.users
	# 	parsedata unless defined? $data # does not need to be updated
	# 	leagueplayers # adds league players to $leagues
	# 	@players = $leagues[@league.id]
	# 	@teams = Hash.new
	# 	@usersclean = Hash.new
	# 	@users.each do |user|
	# 		@teams[user.id] = user.players.map {|player| player.id} unless user.players.count == 0
	# 		@usersclean[user.id] = {id: user.id, name: user.name, team_name: user.team_name, league_id: user.league_id, money: user.money, gwpoints: user.gwpoints, totpoints: user.totpoints}
	# 	end
	# 	boughtplayers = @teams.values.flatten # creates array of bought player's ids (not data id)
	# 	@freeplayers = @league.players.map {|player| player.id}

	# 	# @freeplayers = Array (1..$leagues[@user.league_id].length) #change this take all player ids
		
	# 	@freeplayers -= boughtplayers

	# 	# MOCK DATA #######
	# 	p "@userclean ---------"
	# 	p @userclean
	# 	p "@usersclean ---"
	# 	p @usersclean
	# 	p "@players ------"
	# 	p @players
	# 	p "@teams --------"
	# 	p @teams
	# 	p "@freeplayers --"
	# 	p @freeplayers





	# 	render :index
	# end

	def newgameweek # changes to next gameweek and transfers becomes active
		# check if user is admin
		user = current_user
		if user.admin
			if transfers_active?
				set_owned_true # TODO: Make these two work in new format
				subtract_salaries
			end
			p "<=><=><=><=><=><=> in newgameweek before calc_points"
			calc_points
			p "<=><=><=><=><=><=> in newgameweek after calc_points"
			nextGW = current_gameweek + 1
			log = Log.create(action: 'newgameweek', game_week: nextGW)
			p log
			render json: {response: 'New Game Week', gameweek: nextGW}
		else
			render json: {err: 'Not Autherized to Start New GameWeek'}, status: 401
		end 
	end

	def stoptransfers
		user = current_user
		if user.admin && transfers_active?
			p "in stop transfers"
			set_owned_true
			subtract_salaries
			log = Log.create(action: "stoptransfers", game_week: current_gameweek)
			p "log created: #{log}"
			render json: {response: 'Transfers Stopped'}
		elsif transfers_active?
			render json: {err: 'Not Autherized to Stop Transfers'}, status: 401
		else
			render json: {err: 'Transfers already Stopped'}, status: 422
		end
	end

	def bid
		require 'yaml'
		bid = params[:bid].to_i
		user = current_user
		sentPlayer = params[:player]
		if $leagueplayers[league.id].nil?
			loadleagueplayers(user.league) # adds this league's players to the global scope
		end
		byebug
		player = $leagueplayers[user.league_id][sentPlayer["id"]]
# Player changed on server
		unless player.value == sentPlayer[:value] && player.user_id == sentPlayer[:user_id] && player.owned == sentPlayer[:owned]
			render json: {err: "Player has changed on the server"}, status: 422
		else
			playername = $playerdata[player.id].web_name
# Player owned by bidder, just updating the topbid
			if user.id == sentPlayer.user_id 
				player.topbid = bid
			else
# Player is a free agent, not owned by anyone
				if player.user_id.nil?
					fee = user.money - player.value
					user.update_attributes(money: fee) # subtracts the value of the player from user's money
					@topbid = bid
				  @user_id = id
					logmessage = "#{user.team_name} bought #{playername} for £#{player.value}"
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
						logmessage = "#{user.team_name} successfully bought #{playername} from #{owner.team_name} for £#{player.value}"
					else
# bid increases value of player for current owner
						unless player.owned
							value_increase = owner.money - (bid - player.value)
							owner.update_attributes(money: value_increase)
						end							
						player.value = bid
						logmessage = "#{user.team_name} unsuccessfully bid on #{playername} from #{owner.team_name} for £#{player.value}"
					end
					player.salary
					player.sellvalue
				end
				Log.create(action: "bid", game_week: $current_gameweek, user_id: user.id, player_id: player.id, league_id: user.league_id, value: player.value, message: logmessage)
			end
			serialized_players = YAML::dump $leagueplayers[league.id]
			league.update_attributes(players: serialized_players)
			render json: {response: player} # TODO: send 20 last logs/for now only update logs when visiting logs tab in view
		end
	end

	def sell
		p "-- In transfers#sell params: #{params}"
		user = current_user
		player = Player.where(id: params[:id], league_id: user.league_id).first
		# update player to have user_id, topbid and owned false
		if player.user_id == user.id # change this back to ==
			value = (player.value * 0.9).round
			# if player was owned refund 90%
			if player.owned
				user.update_attributes(money: user.money + value)
			else # else subtract 10% of player value
				loss = user.money - (player.value * 0.1).round
				user.update_attributes(money: loss)
			end
			Log.create(action: "sell", game_week: current_gameweek, user_id: user.id, player_id: player.id, league_id: user.league_id, value: value)
			Log.where(action: "bid", game_week: current_gameweek, player_id: player.id, league_id: user.league_id).update_all(action: "old_bid")
			player.update_attributes(user_id: nil, value: value ,owned: false, topbid: nil)
			render json: {response: 'player sold', money: current_user.money}
		else # player has been bought by someone already or couldn't be found
			render json: {err: 'Player was no longer yours', player: player}, :status => 422
		end
	end

	private
	def calc_points
		getplayerpoints

	end

	def set_owned_true
		Player.where.not(user_id: nil).update_all(owned: true)
	end

	def subtract_salaries
		players = Player.where.not(user_id: nil)
		salaries = players.each_with_object(Hash.new(0)) {|player, sum| sum[player.user_id] += player.value} 
		owners = User.where(id: salaries.keys)
		owners.each do |owner|
			salary = (salaries[owner.id] * 0.1).round # SALARY SET HERE, currently 10% of value
			money = owner.money - salary 
			owner.update_attributes(money: money)
			Log.create(action: "salaries", game_week: current_gameweek, user_id: owner.id, league_id: owner.league_id, value: salary)
		end
	end

end
