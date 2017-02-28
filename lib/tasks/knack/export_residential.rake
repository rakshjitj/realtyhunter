namespace :knack do
  desc "export residential ids from knack"
  task :export_residential => :environment do
    include KnackInterface

    log = ActiveSupport::Logger.new('log/export_residential.log')
    start_time = Time.now

    puts "Exporting residential from knack..."
    log.info "Exporting residential from knack..."

    listings = ResidentialListing.active
    listings.each do |listing|
      cr = CreateResidentialListing
      cr.perform(listing.id, true) # is_now_active = true
    end

    puts "Done!\n"
    log.info "Done!\n"
    end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
    log.close
  end
end
