class League < ActiveRecord::Base
	has_many :users
	has_many :players
	has_many :logs
end
