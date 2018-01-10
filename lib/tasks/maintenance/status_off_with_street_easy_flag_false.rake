
namespace :maintenance do
	desc "Streeteasy flag false when status off"
	task :status_off_with_street_easy_flag_false => :environment do
		log = ActiveSupport::Logger.new('log/status_off_with_street_easy_flag_false.log')
		start_time = Time.now

		puts "Streeteasy flag false when status off and pending..."
		log.info "Streeteasy flag false when status off and pending..."

		@residential_unit = Unit.where(status: [1,2])
		@residential_unit.each do |res_unit|
			if res_unit.residential_listing
				res_unit.residential_listing.update_columns(streeteasy_flag: false)
			end
		end
		# @users = User.all
		# @users.each {|u|
		# 	#if u.name != 'Blank Slate'
		# 		u.update!(password: 'myspace123456', password_confirmation: 'myspace123456')
		# 	#end
		# }

		puts "Done!\n"
		log.info "Done!\n"
		end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
		log.close
	end
end