source 'https://rubygems.org'

ruby '2.3.0'
gem 'mime-types', '~> 3.0'#, require: 'mime/types/columnar'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.3'
# Use postgres as the database for Active Record
gem 'pg', '~> 0.18.4'
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails', '~> 4.1.0'
gem 'jquery-ui-sass-rails', '~> 4.0.3.0'
gem 'turbolinks', '~> 2.5.3'
gem 'jquery-turbolinks', '~> 2.1.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
## Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'
gem 'bootstrap-sass', '>= 3.3.4'
gem 'kaminari', '~> 0.16.3'
gem 'bootstrap-kaminari-views', '~> 0.0.5'
gem 'jquery-infinite-pages', '~> 0.2.0'
gem 'autoprefixer-rails', '~> 6.3.3.1'
# for handling single image uploads
gem "paperclip"
gem 'aws-sdk-v1', '~> 1.52.0' #paperclip
# ajax drag/dropping multiple files
gem 'dropzonejs-rails', '~> 0.7.3'
gem 'mandrill-api', '~> 1.0.53'
gem "rolify", '~> 5.0.0'
gem 'cancancan', '~> 1.10'
#used to add semi-realistic users
#gem 'faker'
# gem 'ffaker'
# autocomplete fields (like building addresses in our case)
gem 'rails4-autocomplete', '1.1.1'
gem 'wicked_pdf', '1.0.5'
gem 'rack-cors', require: 'rack/cors'
# used for our rake tasks to import data
gem 'mechanize'
# make sure we handle time zones correctly
gem 'local_time'
#gem 'dalli', '~> 2.7.6'
gem 'redis-rails'
gem 'resque', '~> 1.22.0'
gem 'delayed_paperclip', '>= 2.9.1'
gem 'momentjs-rails', '>= 2.9.0'
gem 'bootstrap3-datetimepicker-rails', '>= 4.14.30'
gem 'active_model_serializers', github: 'rails-api/active_model_serializers'
gem 'bootsy'
gem 'wuparty' # wufoo
#gem "brakeman", :require => false
gem 'selectize-rails'
gem 'nested_form_fields'
gem 'puma_worker_killer'
gem 'rollbar', '~> 2.8.3'
gem 'activerecord-import'
gem 'oj'
gem 'oj_mimic_json'
# profiling
# gem 'rack-mini-profiler', require: false
# gem 'flamegraph'
# gem 'stackprof'
# gem 'memory_profiler'

group :production do
	gem 'rails_12factor', '0.0.3' # related to serving static assets
	gem 'puma'
	gem 'wkhtmltopdf-heroku', '~> 2.12.2.1'
  gem 'connection_pool', '~> 2.2.0'
  gem 'newrelic_rpm', '~> 3.15.0.314'
  gem 'skylight'
end

group :development, :test do
  gem 'wkhtmltopdf-binary-edge', '~> 0.12.2.1'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', '8.2.2'
  # Access an IRB console on exception pages or by using <%= console %> in views
  # gem 'web-console', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '1.6.4'
end

group :development do
  gem 'rb-readline'
  #gem "bullet"
  #gem 'sql-logging'
  #gem 'better_errors'
  #gem 'derailed'
  #gem 'stackprof'
end

group :test do
  gem 'factory_girl_rails', '~> 4.0'
  gem 'database_cleaner'
end
