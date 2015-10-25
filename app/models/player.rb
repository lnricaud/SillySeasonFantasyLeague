class Player < ActiveRecord::Base
	has_many :logs
	belongs_to :user
	belongs_to :league
end
