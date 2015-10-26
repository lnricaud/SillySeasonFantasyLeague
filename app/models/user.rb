class User < ActiveRecord::Base
	has_secure_password
	validates :email, presence: true, uniqueness:true

	has_many :players
	has_many :logs
	belongs_to :league

	def self.confirm(params)
		@user = User.find_by({email: params[:email]})
		@user.try(:authenticate, params[:password])
	end
end
