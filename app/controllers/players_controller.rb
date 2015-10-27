class PlayersController < ApplicationController
	def refresh
		require 'open-uri'
		require 'json'
		
		@player_data = JSON.parse(open("http://fantasy.premierleague.com/web/api/elements/119/").read)
		p @player_data
		# byebug
		render :index
	end
end
