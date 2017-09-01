require 'date'
desc "This task is called by the Heroku scheduler add-on"
task :run_reports => :environment do
  if Date.today.sunday?
    # unit counts for building/landlord can over time get out of date. we are not properly tracking
    # the cases where a user changes a unit's building/landlord. Instead of updating the old and new
    # landlord, for example, we're only updating the new value. So this is a weekly catch-all that
    # should catch any one-off errors.
    Rake::Task["maintenance:populate_count_fields"].invoke
  end
  if Date.today.monday?
    Rake::Task["maintenance:clear_pending_warning"].invoke
    Rake::Task["maintenance:stale_listings_report"].invoke
  end

	if Date.today.tuesday?
		Rake::Task["maintenance:unassigned_listings"].invoke
    Rake::Task["maintenance:forced_syndication_report"].invoke
    Rake::Task["maintenance:clear_pending"].invoke
	end

  Rake::Task["maintenance:sweep_open_houses"].invoke
  
end
