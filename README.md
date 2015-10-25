# Silly Season Fantasy League
### Fantasy League based on the official [Fantasy Premier League](http://fantasy.premierleague.com). 
* This league is focused on league play. 
* Each player is unique and can only play for one team. 
* Each game week is a silly season.
* Any player can be bought from any manager if the transfer fee is high enough, game week salaries are based on the transfer fee.
* The goal is still focused on getting as many points as possible.
* Player points are both calculated as points and converted to money.
* Transfer fee goes to selling manager or is lost if player was a free agent.
* Buying and paying salaries wastes money.

## User stories
### A user can ...
* create an account and log in. 
* create a new password protected league, the league will be listed for others to join.
* join a league.
* create a team and start making offers on players.
* sell players from own team.
* set salary roof that other managers must bid over in order to buy said player.
* see league table.
* see logs of all activity.

### Stretch goals, a user can ...
* see player stats.
* post suggestions in a forum for changes, others should be able to comment and vote on suggestions.
* filter log entries.
* can navigate through other team's history

## Models
#### User model  
* Has many players
* Has many logs
* Belongs to league
- team_name
- league_id
- user_name

#### Player model
* Belongs to user
* Belongs to league
* Has many logs
- data (json data from official API)
- value
- user_id
- league_id

#### Log model
* Belongs to user
* Belongs to player
* Belongs to league
- user_id
- player_id
- league_id
- text (message)
- action (related to text field, should be a set of allowed actions e.g. bought, sold, bid)
- value (of transfer fee or bid)
- game_week_id (1 - 38)

#### League model
* Has many users
* Has many players
* Has many logs
- league_name

## Wire frames described
1. **Landing page** has login and signup buttons, some information (rules etc.) and possibly an area with related news.
2. After logging in the user arrives at the **team page**. Here the league table is displayed and the team and the user's team. Initially the team will be in list form but as a stretch the team should be displayed graphically.
3. The nav bar can take you to the **transfer page** where you have recent logs and possibility to buy, sell, make a bid and set salary roof on your players.
