class LeaguesController < ApplicationController
	def create
		league_params = params.require(:league).permit(:name)
		p "CREATING A LEAGUE #{league_params}"
		@league = League.create(league_params)
		p "League created? #{!@league.nil?}, #{@league.id}"
		if @league.id.nil?
			p "ERROR! League not created!"
			redirect_to "/leagues/new"
		else
			login(@league)
			p "/teams/#{@league.id}"
			redirect_to "/teams/#{@league.id}" 
		end
	end
end
