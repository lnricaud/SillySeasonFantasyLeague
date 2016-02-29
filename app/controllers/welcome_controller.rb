class WelcomeController < ApplicationController
  def index
    # @post = Post.find(params[:id])
    
    # if stale?(last_modified: @post.updated_at, public: true)
    #   render json: @post
    # end
    render :json => "hello => world"
  	# @user = current_user
  	# if @user
  	# 	if @user.league_id.nil?
	  #   	redirect_to "/leagues/new"
	  #   else
	  #   	redirect_to "/leagues/#{@user.id}"
	  #   end
  	# else
  	# 	render :index
  	# end
  end
end
