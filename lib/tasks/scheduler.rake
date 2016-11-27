require 'date'
desc "This task is called by the Heroku scheduler add-on"
task :run_reports => :environment do
  if Date.today.monday?
    Rake::Task["maintenance:clear_pending_warning"].invoke
  end

	if Date.today.tuesday?
		Rake::Task["maintenance:unassigned_listings"].invoke
    Rake::Task["maintenance:forced_syndication_report"].invoke
    Rake::Task["maintenance:clear_pending"].invoke
	end

  Rake::Task["maintenance:stale_listings_report"].invoke
end

task :run_wufoo_import => :environment do
	Rake::Task["import:wufoo"].invoke
end
