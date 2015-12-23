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

## Quick setup
Make sure that you are running Postgres.  

In a terminal execute the following:
```
$ git clone https://github.com/larskris/SillySeasonFantasyLeague
$ cd SillySeasonFantasyLeague
$ bundle install
$ rake db:create
$ rake db:migrate
$ rails server
```
Check the output for the localhost port in your terminal.

In a browser go to "localhost:xxxx" (xxxx is the port number)


To catch emails from the application, start mailcatcher in terminal
```
$ mailcatcher
```
In a browser go to "http://127.0.0.1:1080" for virtual inboxer


## Transfer Rules
### For transfers the Players model has four important fields:
* user_id: the user who owns the player
* value: current value of player
* topbid: current highest bid on player by current owner
* owned: true if user has owned player over a gameweek, user cannot make a profit from a player when sold if this field is false


### Buy free agent
* value subtracted from user's money
* player marked with topbid


### Buy from other user when player is marked as not owned (player bought in the same transfer round)

- if bid larger than topbid
	* all invested money is returned to other user, no loss or profit
	* topbid + 100k (or bid if less than topbid + 100k) is taken from user
	* player marked with topbid

- if bid smaller than topbid
	* value of player goes up to bid, difference is taken from other user's money
	* player remains in other user's possession


### Buy from other user when player is marked as owned (player bought before last game week, other user received points (if any) for player at least once)

- if bid larger than topbid
	* ownership of player change to bidding user and player is marked as not owned
	* user pays topbid + 100k (or bid) to other user
	* player marked with new topbid

- if bid smaller than topbid
	* value of player goes up to bid
	* no money drawn from owner of player, increased salary will be paid instead


### Sell player
* player fields changed to nil, value set to 90% of previous value
* seller receives 90% of previous value



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
###### Relationships
* Has many players
* Has many logs
* Belongs to league

###### Attributes
- team_name
- league_id
- user_name

#### Player model
###### Relationships
* Belongs to user
* Belongs to league
* Has many logs

###### Attributes
- data (json data from official API)
- value
- user_id
- league_id
- owned
- topbid

#### Log model
###### Relationships
* Belongs to user
* Belongs to player
* Belongs to league

###### Attributes
- user_id
- player_id
- league_id
- text (message)
- action (related to text field, should be a set of allowed actions e.g. bought, sold, bid)
- value (of transfer fee or bid)
- game_week_id (1 - 38)

#### League model
###### Relationships
* Has many users
* Has many players
* Has many logs

###### Attributes
- league_name
- user_id (admin)


## Logs
Logs keep track of events. Logs are of the following kind:

* newPlayer - created when new player is added to API data
* stoptransfers - created before the first game starts, stops transfers until newgameweek has been created
* newgameweek - created after games have been played, calculates the points for each user and activates transfers
* gwpoints - created for each user after each game week. Shows the total points for that game week from user's players
* bid - created when user bids on players.
* salaries - created when transfers are stopped. 10% of the total value of user's players are subtracted from user's money.



## Wire frames described
1. **Landing page** has login and signup buttons, some information (rules etc.) and possibly an area with related news.
2. After logging in the user arrives at the **team page**. Here the league table is displayed and the team and the user's team. Initially the team will be in list form but as a stretch the team should be displayed graphically.
3. The nav bar can take you to the **transfer page** where you have recent logs and possibility to buy, sell, make a bid and set salary roof on your players.


## App flow chart

Controllers are located in ./app/controllers/

Routes are defined in ./**config/routes.rb**

VERB "URL path", to: "controller#method", as: "optional_alias" (optional alias path accessed by adding _path i.e. "optional_alias_path"

See all routes in terminal with command: $ rake routes

root url goes to welcome controller and the index method (welcome#index).

*Controller*  
**welcome#index**

1. Displays a message if user not logged in.

If logged in: 

2. Redirects to team page if user is logged in and belongs to a league.
3. Otherwise redirects user to leagues#new

*Controller*  
**leagues#new**

1. Checks if user is logged in, redirects to sign_in if not.

If logged in: 

2. Prepares @league if user wants to create new league
3. Creates a list of all existing leagues in variable @leagues for user to join.
4. Renders view ./app/views/leagues/new.html.erb

*View*  
./app/views/**leagues/new.html.erb**  
Submit button posts to leagues#create  
*Controller*
**leagues#create**

1. League is created and user is updated in db to belong to created league
2. Redirected to team page

Clicking on a league redirects to leagues#show with league id in params  
*Controller*  
**leagues#show**

3. @league is found in the db by id
4. @users is an array of users who belongs to that league. Relationship defined in leagues.rb and users.rb models. User schema has league_id as int column.
5. @admin is defined in the League schema in user_id column.
6. Renders ./app/views/leagues/show.html.erb

*View*  
./app/views/**leagues/show.html.erb**
Lists creator of league and all teams and managers

1. Back button redirects back to ./app/views/leagues/new.html.erb
2. Join button redirects to leagues#join and passes on the league id in params

*Controller*  
**leagues#join**

1. Updates user.league_id in db
2. Redirects to team page

*Controller*  
**teams#show**

1. Checks if user logged in, if no redirects to login/signup page

If logged in: 

2. @league, @users created for view
3. Checks if user has chosen a team name, if not redirects to ./app/views/teams/name.html.erb
./app/views/**teams/name.html.erb**
Submit button posts to teams#name where User.team_name is updated in the db.




