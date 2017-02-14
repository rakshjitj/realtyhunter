namespace :knack do
  desc "update residential listing in knack"
  task :update_residential => :environment do
    include KnackInterface

    log = ActiveSupport::Logger.new('log/knack_update_residential_listing.log')
    start_time = Time.now

    puts "Sending updated residential listing to knack..."
    log.info "Sending updated residential listing to knack..."

    cr = UpdateResidentialListing
    cr.perform(13706) # 173 Herkimer

    puts "Done!\n"
    log.info "Done!\n"
    end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
    log.close
  end
end
