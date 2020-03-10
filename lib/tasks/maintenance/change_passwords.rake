namespace :maintenance do
	desc "clean up to match latest schema changes"
	task :change_passwords => :environment do
		log = ActiveSupport::Logger.new('log/change_passwords.log')
		start_time = Time.now

	  company = Company.find_by(name: 'MyspaceNYC')

		puts "Changing passwords..."
		log.info "Changing passwords..."

		@users = User.all
		@users.each {|u|
			#if u.name != 'Blank Slate'
				u.update!(password: 'zumPer2020MSnyc', password_confirmation: 'zumPer2020MSnyc')
			#end
		}

		puts "Done!\n"
		log.info "Done!\n"
		end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
		log.close
	end
end
