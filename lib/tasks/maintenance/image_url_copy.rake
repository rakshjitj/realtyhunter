namespace :maintenance do
	desc "Copy Image url in Images"
	task :image_url_copy => :environment do
		log = ActiveSupport::Logger.new('log/email_copy_to_streeteasy_email.log')
		start_time = Time.now

		puts "Copy image url to large_image_url..."
		log.info "Copy image url to large_image_url..."

		@images = Image.all
		@images.each do |image|
			puts "update image #{image.id}"
			image.update_columns(large_image_url: image.file(:large))
			image.update_columns(thumb_image_url: image.file(:thumb))
			puts "image url updated successfully"
		end

		# @units = Unit.all
		# @units.each do |unit|
		# 	#if !unit.images.blank?
		# 		puts "update unit #{unit.id}"
		# 		unit.images.each do |image|
		# 			puts "image id #{image.id}"
		# 			image.update_columns(large_image_url: image.file(:large))
		# 			puts "image updated successfully.................."
		# 		end
		# 	#end
		# 	#user.update_columns(streeteasy_email: user.email, streeteasy_mobile_number: user.mobile_phone_number)
		# end
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