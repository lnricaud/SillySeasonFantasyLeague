class SignupMailer < ApplicationMailer
	default from: "kristian@tutamail.com"

	def signup_mail(user)
	  @user = user
	  email_with_name = "#{@user.name} <#{@user.email}>"
	  @url  = 'http://sillyseasonfantasyleague.herokuapp.com'
	  mail(to: email_with_name, subject: 'Thank you for signing up to play Silly Season Fantasy League!')
	end	
end
