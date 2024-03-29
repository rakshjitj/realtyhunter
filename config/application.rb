require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RealtyHunter
  class Application < Rails::Application
    config.middleware.use Rack::Deflater
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
    config.autoload_paths += %W(#{config.root}/lib #{config.root}/app/models) # add this line
    config.assets.precompile += ['application.css', 'print.css']

    config.middleware.insert_before 0, "Rack::Cors", :debug => true, :logger => (-> { Rails.logger }) do
      allow do
        origins '*'

        resource '/cors',
          :headers => :any,
          :methods => [:post],
          :credentials => true,
          :max_age => 0

        resource '*',
          :headers => :any,
          :methods => [:get, :post, :delete, :put, :options, :head],
          :max_age => 0
      end
    end

    config.action_mailer.default_url_options = { host: 'myspace-realty-monster.herokuapp.com' }
    config.action_mailer.asset_host = 'https://myspace-realty-monster.herokuapp.com'

    config.active_job.queue_adapter = :resque
    config.action_view.embed_authenticity_token_in_remote_forms = true
    config.time_zone = 'Eastern Time (US & Canada)'
    ActiveSupport.halt_callback_chains_on_return_false = false
    config.active_record.time_zone_aware_types = [:datetime, :time]
    config.assets.initialize_on_precompile = false
    #config.action_mailer.delivery_method = :postmark
    #config.action_mailer.postmark_settings = { :api_token => "0fff3a86-d3a2-446e-84e4-6f15458186e4" }
    Slack.configure do |config|
      config.token = ENV['SLACK_API_TOKEN']
    end
  end
end


