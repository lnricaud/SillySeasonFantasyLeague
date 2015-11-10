module TransfersHelper
	def current_gameweek
		@gw = Log.maximum(:game_week) || 0 # make sure this doesn't break if called during gw 1 but before first gw log has been made 
	end

	def transfers_active?
		Log.where(game_week: current_gameweek, action: "newgameweek")
	end
end
