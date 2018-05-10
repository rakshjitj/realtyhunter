namespace :maintenance do
	desc "clean up to match latest schema changes"
	task :add_image_url_for_specific_listings => :environment do
		log = ActiveSupport::Logger.new('log/add_image_url_for_specific_listings.log')
		start_time = Time.now

		puts "Copy image url to large_image_url..."
		log.info "Copy image url to large_image_url..."

		@images = Image.where(large_image_url: nil)
		@images.each do |image|
			puts "update image #{image.id}"
			image.update_columns(large_image_url: image.file.url(:large))
			image.update_columns(thumb_image_url: image.file.url(:thumb))
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
