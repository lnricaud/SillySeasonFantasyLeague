class Player
  def initialize(playerdata_id, league_id)
    startvalue = 4000000
    @league_id = league_id
    @playerdata_id = playerdata_id
    @value = startvalue
    @topbid = startvalue
    @gw_value = startvalue
    @owned = false
  end
  def salary
    (@value*0.9).round
  end
  def data
    # get data for for player, need to refactor the data element first
  end
end