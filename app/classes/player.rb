class Player
  attr_reader :id, :sellvalue, :salary
  attr_accessor :value, :topbid, :gw_value, :user_id, :user_name, :owned

  def initialize(playerdata_id)
    startvalue = 4000000
    @id = playerdata_id
    @value = startvalue
    @sellvalue = self.sellvalue
    @salary = self.salary
    @topbid = startvalue
    @gw_value = startvalue
    @user_id = nil
    @owned = false # indicates if the player was bought before transfer stop
  end
  def sell
    @user_id = nil
    @owned = false
    @value = @sellvalue
    @topbid = @sellvalue
    @salary = self.salary
    @sellvalue = self.sellvalue
    return @value
  end
  def salary
    salary = 0.2
    @salary = (@value*salary).round
  end
  def sellvalue
    sellvalue = 0.9
    @sellvalue = (@value*sellvalue).round
  end
end

class Playerstats
  attr_reader :id, :web_name, :first_name, :last_name, :team_name, :position, :team_id, :current_fixture, :next_fixture, :news, :fixtures_played, :fixtures_last3, :fixtures_next, :fixtures_next3, :gw_points, :gw_plays, :gw_plays_next, :gw_details, :total_points, :minutes, :points_per_game, :goals_scored, :assists, :clean_sheets, :goals_conceded, :own_goals, :penalties_saved, :penalties_missed, :yellow_cards, :red_cards, :saves, :bonus, :season_history

  def initialize(data)
    @id = data["id"]
    @web_name = data["web_name"]
    @first_name = data["first_name"]
    @last_name = data["second_name"]
    @team_name = data["team_name"]
    @position = data["type_name"]
    @team_id = data["team_id"]
    @current_fixture = data["current_fixture"]
    @next_fixture = data["next_fixture"]
    @news = data["news"]
    @fixtures_played = data["fixture_history"]["all"]
    @fixtures_last3 = data["fixture_history"]["summary"]
    @fixtures_next = data["fixtures"]["all"]
    @fixtures_next3 = data["fixtures"]["summary"]
    @gw_points = data["event_total"]
    @gw_plays = data["chance_of_playing_this_round"]
    @gw_plays_next = data["chance_of_playing_next_round"]
    @gw_details = data["event_explain"]
    @total_points = data["total_points"]
    @minutes = data["minutes"]
    @points_per_game = data["points_per_game"]
    @goals_scored = data["goals_scored"]
    @assists = data["assists"]
    @clean_sheets = data["clean_sheets"]
    @goals_conceded = data["goals_conceded"]
    @own_goals = data["own_goals"]
    @penalties_saved = data["penalties_saved"]
    @penalties_missed = data["penalties_missed"]
    @yellow_cards = data["yellow_cards"]
    @red_cards = data["red_cards"]
    @saves = data["saves"]
    @bonus = data["bonus"]
    @season_history = data["season_history"]
  end
end
