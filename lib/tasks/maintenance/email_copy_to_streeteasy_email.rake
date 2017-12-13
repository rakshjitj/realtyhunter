namespace :maintenance do
	desc "Copy Email to StreetEasy Email in User"
	task :email_copy_to_streeteasy_email => :environment do
		log = ActiveSupport::Logger.new('log/email_copy_to_streeteasy_email.log')
		start_time = Time.now

		puts "Copy email to streeteasy_email..."
		log.info "Copy email to streeteasy_email..."

		@users = User.all
		@users.each do |user|
			user.update_columns(streeteasy_email: user.email, streeteasy_mobile_number: user.mobile_phone_number)
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