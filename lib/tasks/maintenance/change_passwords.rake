namespace :maintenance do
	desc "clean up to match latest schema changes"
	task :change_passwords => :environment do
		log = ActiveSupport::Logger.new('log/import_landlords.log')
		start_time = Time.now

	  company = Company.find_by(name: 'MyspaceNYC')

		puts "Changing passwords..."
		log.info "Changing passwords..."

		@users = User.all
		@users.each {|u|
			if u.name != 'Blank Slate'
				u.update!(password: '123456', password_confirmation: '123456')
			end
		}

		puts "Done!\n"
		log.info "Done!\n"
		end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
		log.close
	end
end