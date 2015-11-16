module PlayersHelper
	def parsedata
		playerdata = Playerdata.all
		$data = Hash.new
		data = playerdata.map {|player| JSON.parse(player.data)}
		data.each {|player| $data[player["id"]] => player}
		#MAke this work
	end
end
