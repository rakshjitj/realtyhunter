require 'date'
desc "This task is called by the Heroku scheduler add-on"
task :run_reports => :environment do
	if Date.today.tuesday?
		Rake::Task["maintenance:unassigned_listings"].invoke
	end
end
task :run_wufoo_import => :environment do
	Rake::Task["import:wufoo"].invoke
end
