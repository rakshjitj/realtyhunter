source 'https://rubygems.org'

#gem 'mime-types', '~> 2.4.3', require: 'mime/types/columnar'
ruby '2.3.0'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.3'
# Use postgres as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# Use jquery as the JavaScript library
gem 'jquery-rails'
# TODO: no longer maintained. need to find replacement eventually:
gem 'jquery-ui-sass-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'jquery-turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
## Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'
gem 'bootstrap-sass', '~> 3.3.4'
gem 'kaminari'
gem 'bootstrap-kaminari-views'
gem 'jquery-infinite-pages'
gem 'autoprefixer-rails'
# for handling single image uploads
gem "paperclip"
gem 'aws-sdk-v1' #paperclip
# ajax drag/dropping multiple files
gem 'dropzonejs-rails'
# sending emails
gem 'mandrill-api'
# roles authorization
gem "rolify"
gem 'cancancan', '~> 1.10'
#gem 'faker' - used to add semi-realistic users
# gem 'ffaker'
# autocomplete fields (like building addresses in our case)
gem 'rails4-autocomplete'
#gem 'pdfkit'
gem 'wicked_pdf'
# trying to get past font/cors issues...
gem 'rack-cors', require: 'rack/cors'
# used for our rake tasks to import data
gem 'mechanize'
# make sure we handle time zones correctly
gem 'local_time'
# caching
gem 'dalli'
# background workers
gem 'redis-rails'
gem 'resque', '~> 1.22.0'
gem 'delayed_paperclip'
gem 'momentjs-rails', '>= 2.9.0'
gem 'bootstrap3-datetimepicker-rails', '~> 4.14.30'
gem 'rollbar', '~> 1.2.7'
gem 'active_model_serializers', github: 'rails-api/active_model_serializers'
gem 'bootsy'
# wufoo
gem 'wuparty'
gem 'selectize-rails'
gem 'nested_form_fields'
gem 'puma_worker_killer'

group :production do
	gem 'rails_12factor' # related to serving static assets
	gem 'puma'
	gem 'wkhtmltopdf-heroku', '~> 2.12.2.1'
  gem 'connection_pool'
  gem 'newrelic_rpm'
end

group :development, :test do
  gem 'wkhtmltopdf-binary-edge', '~> 0.12.2.1'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :development do
  gem 'rb-readline'
  # gem "bullet"
  #gem 'sql-logging'
  #gem 'better_errors'
  # gem 'derailed'
  # gem 'rack-mini-profiler'
  # gem 'flamegraph'
  # gem 'stackprof'
  # gem 'memory_profiler'
end

group :test do
  gem 'factory_girl_rails', '~> 4.0'
  gem 'database_cleaner'
end
