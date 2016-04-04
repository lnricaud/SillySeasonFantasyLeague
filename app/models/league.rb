class League < ActiveRecord::Base
	has_secure_password
	validates :league_name, presence: true, uniqueness:true

	has_many :users
	has_many :players
	has_many :logs
end
