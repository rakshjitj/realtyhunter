namespace :import do
  desc "Import Nestio's user data into our database"
  task :import_everything => :environment do

  	Rake::Task['import:users'].execute
  	Rake::Task['import:landlords'].execute
  	Rake::Task['import:zillow_listings'].execute
  	Rake::Task['import:residential'].execute
  	Rake::Task['import:match_units'].execute
    
	end
end