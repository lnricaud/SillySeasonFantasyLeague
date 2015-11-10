module TransfersHelper
	def current_gameweek
		@gw = Log.maximum(:game_week) || 1
	end

	def transfers_active?
		Log.where(game_week: current_gameweek, action: "trans_stop")
	end
end
