class TransfersController < ApplicationController
	def index
		require 'json'
		@user = current_user
		@league = @user.league
		@users = @league.users
		parsedata unless defined? $data # does not need to be updated
		leagueplayers # adds league players to $leagues
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

	def newgameweek # changes to next gameweek and transfers becomes active
		if transfers_active?
			set_owned_true
			subtract_salaries
		end
		calc_points
		
		nextGW = current_gameweek + 1
		log = Log.create(action: 'newgameweek', game_week: nextGW)
		p log
		redirect_to "/transfers" 
	end

	def stoptransfers
		p "in stop transfers"
		set_owned_true
		subtract_salaries
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
					updated_attributes = {value: value, user_id: user.id, owned: false, topbid: bid}
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
		# update player to have user_id, topbid and owned false
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
		player.update_attributes(user_id: nil, value: value ,owned: false, topbid: nil)
		redirect_to "/transfers"
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
