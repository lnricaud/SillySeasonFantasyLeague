# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Clear database
League.destroy_all
User.destroy_all
Player.destroy_all
Log.destroy_all

5.times do |i|
	league_name = FFaker::Product.brand
	league = League.create({league_name: league_name})
	p "-------------"
	p "League #{league_name}"
	10.times do
		fname = FFaker::Name.first_name
		lname = FFaker::Name.last_name
		domain = FFaker::Internet.domain_name
		email = "#{lname}@#{domain}"
		team_pre = FFaker::HealthcareIpsum.word
		team_name = "#{team_pre.capitalize} FC"
		data = {name: "#{fname} #{lname}", email: email, password: "qwe", team_name: team_name, league_id: league.id, money: 100000000}
		@user = User.create(data)
		p "User #{email} | 'qwe'"
	end
	updated_attributes = {:user_id => @user.id}
	league.update_attributes(updated_attributes)	
end
