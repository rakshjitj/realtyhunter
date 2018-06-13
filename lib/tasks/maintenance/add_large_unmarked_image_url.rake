namespace :maintenance do
	desc "clean up to match latest schema changes"
	task :add_large_unmarked_image_url => :environment do
		log = ActiveSupport::Logger.new('log/add_large_unmarked_image_url.log')
		start_time = Time.now

		puts "Copy large unmarked image url to large_image_url..."
		log.info "Copy large unmarked image url to large_image_url..."

		@images = Image.where.not(user_id: nil)
		@images.each do |image|
			puts "update image #{image.id}"
			image.update_columns(large_unmarked_image_url: image.file.url(:large_unmarked))
			puts "image url updated successfully"
		end

		puts "Done!\n"
		log.info "Done!\n"
		end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
		log.close
	end
end
