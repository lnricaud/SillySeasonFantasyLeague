class TransfersController < ApplicationController
	def index
		@user = current_user
		@league = @user.league
		@players = @league.players
		@users = @user.league.users
		@teams = Hash.new
		p "--- STARTS HERE ---"
		@users.map do |user|
			p "user: #{user}"
			p user.id
			@teams[user.id] = user.players

		# byebug
		end 
	end

	def newgameweek # changes to next gameweek
		nextGW = current_gameweek + 1
		logParams = {action: 'newgameweek', game_week: nextGW}
		p "logParams: #{logParams}"
		log = Log.create(action: 'newgameweek', game_week: nextGW)
		p log
		calc_points
		redirect_to "/leagues/#{current_user.id}" 
	end

	def stoptransfers
		Log.
		Log.create({action: "stoptransfers", game_week: current_gameweek})
	end

	private
	def calc_points

	end
end
