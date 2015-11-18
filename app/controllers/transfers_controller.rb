class TransfersController < ApplicationController
	def index
		require 'json'
		@user = current_user
		@league = @user.league
		@users = @league.users
		parsedata unless defined? $data # does not need to be updated
		mergeplayerdata # create @players
		@teams = Hash.new
		@users.each do |user|
			p "user: #{user}"
			p user.id
			@teams[user.id] = user.players
		end
		# byebug
		p "@teams: #{@teams}"
		render :index
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
		Log.all
		Log.create({action: "stoptransfers", game_week: current_gameweek})
	end

	private
	def calc_points
# to be called when new game week starts
	end
end
