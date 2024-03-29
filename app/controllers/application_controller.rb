class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception. <--- :exception was default
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  include SessionsHelper
  include Knock::Authenticable
end
