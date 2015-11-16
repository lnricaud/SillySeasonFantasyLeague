module PlayersHelper
	def parsedata
		playerdata = Playerdata.all
		$data = Hash.new
		data = playerdata.map {|player| JSON.parse(player.data)}
		data.each {|player| $data[player["id"]] = player}
		# creates $data that has all player api data in a hash with id as key
		# byebug
	end

	def mergeplayerdata
		@players = Hash.new
		players = @league.players
		players.each do |player| 
			@players[player.id] = {
				data: $data[player.id], # Maybe sort out the data needed here
				
				value: player.value,
				user: player.user_id,
				league: player.league_id
			}
		end
	end



end
