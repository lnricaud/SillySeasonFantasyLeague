class Player
  attr_reader :playerdata_id
  attr_accessor :value, :topbid, :gw_value, :user_id, :owned

  def initialize(playerdata_id)
    startvalue = 4000000
    @playerdata_id = playerdata_id
    @value = startvalue
    @topbid = startvalue
    @gw_value = startvalue
    @user_id = nil
    @owned = false # this indicates if the player was bought before transfer stop
  end
  def salary
    (@value*0.9).round
  end
  def sell
    sellvalue = (@value*0.9).round
    @owned = false
    @value = sellvalue
    @topbid = sellvalue
  end
  def data
    # get data for for player, need to refactor the data element first

  end
end