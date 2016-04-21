module TransfersHelper
	# def current_gameweek
	# 	gwlog = Log.where(action: "newgameweek").last
	# 	return (gwlog.nil? ? 1 : gwlog.game_week)
	# end

	# def transfers_active?
	# 	!Log.exists?({game_week: current_gameweek, action: "stoptransfers"})
	# end
end
