class TransfersController < ApplicationController
	def index
		require 'json'
		@user = current_user
		@league = @user.league
		@users = @league.users
		parsedata unless defined? $data # does not need to be updated
		mergeplayerdata # adds league players to $leagues
		@players = $leagues[@league.id]
		p "PETER IN INDEX: #{@players[3]}"
		@teams = Hash.new
		@users.each do |user|
			@teams[user.id] = user.players.map {|player| player.id} unless user.players.count == 0

		end
		boughtplayers = @teams.values.flatten
		@freeplayers = Array (1..$leagues[@user.league_id].length)
		@freeplayers -= boughtplayers
		render :index
	end

	def newgameweek # changes to next gameweek
		set_owned_true
		nextGW = current_gameweek + 1
		logParams = {action: 'newgameweek', game_week: nextGW}
		p "logParams: #{logParams}"
		log = Log.create(action: 'newgameweek', game_week: nextGW)
		p log
		calc_points
		redirect_to "/transfers" 
	end

	def stoptransfers
		p "in stop transfers"
		set_owned_true
		log = Log.create(action: "stoptransfers", game_week: current_gameweek)
		p "log created: #{log}"
		redirect_to "/transfers"
	end

	def bid
		p "in transfers#bid, params: #{params}"
		bid = params[:bid].to_i
		p "bid value: #{params[:bid]}"
		user = current_user
		player = Player.where(id: params[:id], league_id: user.league_id).first # .first is needed or the relations won't work
		owner = player.user
		
#\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
		highestBid = Log.where(player_id: player.id, league_id: user.league_id, action: "bid").order("value DESC").first
		Log.create(action: "bid", game_week: current_gameweek, user_id: user.id, player_id: player.id, league_id: user.league_id, value: bid)
		# Bought as Kristian but Kochielny got to Peter BUGGGGGGG/ doesn't happen again, will keep an eye out for this
		
		if user == owner
			highestBid.update_attributes({value: bid})
			updated_attributes = {topbid: bid}
		else
			if player.user.nil? # player was a free agent
				updated_attributes = {user_id: user.id, topbid: bid}
				fee = user.money - player.value
				user.update_attributes(money: fee) # subtracts the value of the player from user's money
			else # bidding on a player owned by another user
				if bid > highestBid.value
					# bid buys player
					if bid < highestBid.value + 100000
						value = bid
					else
						value = highestBid.value + 100000
					end
					updated_attributes = {value: value, user_id: user.id, owned: nil, topbid: bid}
					fee = user.money - value
					user.update_attributes(money: fee) # user pays for the player
					if player.owned # owner makes a profit
						profit = owner.money + value
						owner.update_attributes(money: profit)
					else # owner get his money back, no profit
						refund = owner.money + player.value
						owner.update_attributes(money: refund)
					end
				else
					# bid increases value of player for current owner
					value = bid
					updated_attributes = {value: value}
					difference = owner.money - (value - player.value)
					p "difference: #{difference}, owner money: #{owner.money}, bid: #{value}, player value: #{player.value}"
					owner.update_attributes(money: difference) # player value increased, owner compensating for that with the difference
				end
				player.update_attributes(updated_attributes)		
			end
			$leagues[user.league_id][player.id][:value] = value
		end
		player.update_attributes(updated_attributes)
#\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
		redirect_to "/transfers"
	end

	def sell
		p "-- In transfers#sell params: #{params}"
		user = current_user
		player = Player.where(id: params[:id], league_id: user.league_id).first
		# update player to have user_id, topbid and owned nil
		value = (player.value * 0.9).round
		# if player was owned refund 90%
		if player.owned
			user.update_attributes(money: value)
		else # else subtract 10% of player value
			loss = user.money - (player.value * 0.1).round
			user.update_attributes(money: loss)
		end
		Log.create(action: "sell", game_week: current_gameweek, user_id: user.id, player_id: player.id, league_id: user.league_id, value: value)
		Log.where(action: "bid", game_week: current_gameweek, player_id: player.id, league_id: user.league_id).update_all(action: "old_bid")
		player.update_attributes(user_id: nil, value: value ,owned: nil, topbid: nil)
		redirect_to "/transfers"
	end

	private
	def calc_points
# to be called when new game week starts
	end

	def set_owned_true
		Players.where.not(user_id: nil).update_all(owned: true)
	end
end
