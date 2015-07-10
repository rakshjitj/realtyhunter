Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Care if the mailer can't send.
  # Enable email previews
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :test
  host = 'localhost:3000'
  config.action_mailer.default_url_options = { host: host }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  config.after_initialize do
    Bullet.enable = true
    #Bullet.alert = true
    #Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
    Bullet.add_footer = true
    #Bullet.slack = { webhook_url: 'http://some.slack.url', foo: 'bar' }
  end

  config.paperclip_defaults = {
    storage: :s3,
    :s3_credentials => {
      :bucket => ENV['S3_AVATAR_BUCKET'],
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
      :s3_protocol => :https
    }
  }

  # Use a different cache store in production.
  #config.cache_store = :mem_cache_store
  #config.cache_store = :dalli_store#, 
    # (ENV["MEMCACHIER_SERVERS"] || "").split(","),
    # {:username => ENV["MEMCACHIER_USERNAME"],
    #  :password => ENV["MEMCACHIER_PASSWORD"],
    #  :failover => true,
    #  :socket_timeout => 1.5,
    #  :socket_failure_delay => 0.2
    # }
    #{ :namespace => 'realty-monster', :expires_in => 1.day, :compress => true }, 
    #{ :pool_size => 5 }
  #config.action_controller.perform_caching = true
  
end
