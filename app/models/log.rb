class Log < ActiveRecord::Base
	belongs_to :user
	belongs_to :league
end
