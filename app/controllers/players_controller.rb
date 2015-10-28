class PlayersController < ApplicationController
	def refresh
		require 'open-uri'
		require 'json'
		i = 1
		loop do
			begin
			  player_data = open("http://fantasy.premierleague.com/web/api/elements/#{i}/").read  
			rescue OpenURI::HTTPError   
			  p "Found last element, breaking out of loop"
			  break  
			end  
			p player_data["id"]
			db_data = Playerdata.find_by_id(i)
			if db_data.nil?
				p "Creating new Playerdata"
				Playerdata.create(data: player_data)
				p "Adding new Player to all Leagues"
				1.upto(League.count) do |l|
					Player.create({league_id: l, playerdata_id: i, value: 100000000})
				end
			else
				p "Uppdating existing playerdata.data"
				updated_attributes = {:data => player_data}
				db_data.update_attributes(updated_attributes)
			end
			i += 1
		end
		# byebug
		redirect_to "/" 
	end

end
