# Be sure to restart your server when you modify this file.
Rails.application.config.session_store :cookie_store,
  key: '_realty-monster_session',
  domain: :all,
  expire_after: 24.hours

Rails.application.config.session_store ActionDispatch::Session::CacheStore, expire_after: 24.hours
Rails.application.config.session_store :redis_store #, servers: "redis://localhost:6379/0/session"
