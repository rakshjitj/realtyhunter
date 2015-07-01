source 'https://rubygems.org'

ruby '2.2.1'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'
# Use postgres as the database for Active Record
gem 'pg'
#gem 'sqlite3'
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
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'jquery-turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
# Use ActiveModel has_secure_password
 gem 'bcrypt', '~> 3.1.7'
# Use Unicorn as the app server
# gem 'unicorn'
gem 'will_paginate'
gem 'bootstrap-sass', '~> 3.3.4'
gem 'bootstrap-will_paginate'
gem 'autoprefixer-rails'
gem 'better_errors'

#gem "refile", require: "refile/rails"
#gem "refile-mini_magick"
# for handling single image uploads
#gem 'refile-s3'
# for handling multiple image uploads
gem "paperclip"
gem 'aws-sdk-v1' #paperclip
#gem 'aws-sdk' #refile
# ajax drag/dropping multiple files
gem 'dropzonejs-rails'
# sending emails
gem 'mandrill-api'
# roles authorization
gem "rolify"
gem 'cancancan', '~> 1.10'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
#used to add semi-realistic users
gem 'faker'
gem 'ffaker'
# simulate multiple table inheritance
gem 'active_record-acts_as'
# autocomplete fields (like building addresses in our case)
gem 'rails4-autocomplete'
#gem 'pdfkit'
gem 'wicked_pdf'

group :production do
	gem 'rails_12factor'
	gem 'puma'
	gem 'wkhtmltopdf-heroku', '~> 2.12.2.1'
end

group :development, :test do
  gem 'wkhtmltopdf-binary-edge', '~> 0.12.2.1'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :development do
  gem 'rb-readline'
  gem "bullet"
end

group :test do
  gem "factory_girl_rails", "~> 4.0"
  gem 'database_cleaner'
end