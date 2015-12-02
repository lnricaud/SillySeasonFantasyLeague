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
		log = Log.create(action: "stoptransfers", game_week: current_gameweek)
		p "log created: #{log}"
		redirect_to "/transfers"
	end

	def bid
		p "in transfers#bid, params: #{params}"
		bid = params[:bid].to_i
		p "bid value: #{params[:bid]}"
		user = current_user
		league = user.league
		player = Player.where(id: params[:id], league_id: user.league_id).first
		owner = player.user
		
#\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
		# check for highest bid and increase it with 100k if new bid is higher, if not increase current owners price to what current bid was.
		
		highestBid = Log.where(player_id: player.id, league_id: league.id, action: "bid").order("value DESC").first
		Log.create(action: "bid", game_week: current_gameweek, user_id: user.id, player_id: player.id, league_id: league.id, value: bid)
		if highestBid.nil? # player has never been bought
			value = player.value + 100000
			updated_attributes = {value: value, user_id: user.id}
		else
			if bid > highestBid.value
				# bid buys player
				if bid < highestBid.value + 100000
					value = bid
				else
					value = highestBid.value + 100000
				end
					updated_attributes = {value: value, user_id: user.id, owned: nil}
			else
				# bid increases value for current owner
				updated_attributes = {value: bid}
			end
			player.update_attributes(updated_attributes)		
		end
		player.update_attributes(updated_attributes)
		$leagues[user.league_id][player.id][:value] = value
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		redirect_to "/transfers"
	end

	private
	def calc_points
# to be called when new game week starts
	end
end
