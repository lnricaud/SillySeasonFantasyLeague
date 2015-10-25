class User < ActiveRecord::Base
	has_many :players
	has_many :logs
	belongs_to :league
end
