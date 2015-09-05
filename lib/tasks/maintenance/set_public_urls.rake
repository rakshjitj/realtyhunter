namespace :maintenance do
	desc "update listing and agent URLS to match BlankSlate's"
	task set_public_urls: :environment do
		log = ActiveSupport::Logger.new('log/set_public_urls.log')
		start_time = Time.now

		def mark_done(log, start_time)
			puts "Done!\n"
  		log.info "Done!\n"
  		end_time = Time.now
	    duration = (start_time - end_time) / 1.minute
	    log.info "Task finished at #{end_time} and last #{duration} minutes."
	    log.close
		end

		# make into commandline args
		

 		if !done
		  mark_done(log, start_time)
		end
	end
end