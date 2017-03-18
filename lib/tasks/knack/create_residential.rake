namespace :knack do
  desc "export residential listing to knack"
  task :create_residential => :environment do
    include KnackInterface

    log = ActiveSupport::Logger.new('log/create_residential.log')
    start_time = Time.now

    puts "Sending res listing to knack..."
    log.info "Sending res listing to knack..."

    listing = ResidentialListing.where(id: 13706).first
    cr = CreateResidentialListing
    is_now_active = nil
    # cr.perform(13706, is_now_active) # 173 Herkimer
    Resque.enqueue(CreateResidentialListing, listing.id, is_now_active) # 173 Herkimer

    puts "Done!\n"
    log.info "Done!\n"
    end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
    log.close
  end
end
