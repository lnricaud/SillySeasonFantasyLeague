class TeamsController < ApplicationController
	def show
		@user = User.find(params[:id])
		if @user.league_id.nil?
			render :index
		else
			@league = League.find(@user.league_id)
			@users = @league.users
			if @user.team_name.nil?
				@tnames = @users.map {|tname| (tname.team_name unless tname.team_name.nil?) }
				p "tnames: #{@tnames}"
				render :tname
			else
				render :show
			end
		end
	end

	def tname
		p "params in tname: #{params}"
		updated_attributes = {:team_name => params["team_name"]}
		@user = current_user
		@user.update_attributes(updated_attributes)
		redirect_to "/teams/#{@user.id}" 
	end
end
