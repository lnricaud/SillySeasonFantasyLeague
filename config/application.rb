require File.expand_path('../boot', __FILE__)

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)



module SillySeasonFantasyLeague
  class Application < Rails::Application
    # Custom object classes in /app/classes folder
    config.autoload_paths << "#{Rails.root}/app/classes"

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    config.api_only = true
    # config.action_dispatch.default_headers = {
    #     'Access-Control-Allow-Origin' => '*',
    #     'Access-Control-Request-Method' => %w{GET POST OPTIONS}.join(",")
    #     }
    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
      origins '*'
      resource '*', :headers => :any, :methods => [:get, :post, :options]
      end
    end

    ## initialize global variables
    config.after_initialize do
      p "Init $playerdata"
      require 'yaml'
      require 'player'
      if Log.table_exists?
        gwlog = Log.where(action: "newgameweek").last
        $current_gameweek = (gwlog.nil? ? 1 : gwlog.game_week)
        $transfers_active = !Log.exists?({game_week: $current_gameweek, action: "stoptransfers"})
      else
        $current_gameweek = 1
        $transfers_active = true
      end
      $playerdata = Hash.new
      if Playerdata.table_exists?
        db_player_data = Playerdata.last
        unless db_player_data.nil?
          $playerdata = YAML::load db_player_data.data
        end
      end
    end

  end
end


# 'Access-Control-Allow-Origin' => 'http://localhost:3000',