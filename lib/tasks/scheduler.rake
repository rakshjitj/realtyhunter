desc "This task is called by the Heroku scheduler add-on"
task :run_reports => :environment do
	Rake::Task["maintenance:unassigned_listings"].invoke
end
