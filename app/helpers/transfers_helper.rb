module TransfersHelper
	def current_gameweek
		@gw = Log.maximum(:game_week) || 1 # make sure this doesn't break if called during gw 1 but before first gw log has been made 
	end

	def transfers_active?
		!Log.exists?({game_week: current_gameweek, action: "stoptransfers"})
	end
end
