namespace :knack do
  desc "export residential listing to knack"
  task :create_residential => :environment do
    include KnackInterface

    log = ActiveSupport::Logger.new('log/create_residential.log')
    start_time = Time.now

    puts "Sending building to knack..."
    log.info "Sending building to knack..."

    cr = CreateResidentialListing
    cr.perform(13706) # 173 Herkimer
    # Resque.enqueue(CreateResidentialListing, listing.id) # 173 Herkimer

    puts "Done!\n"
    log.info "Done!\n"
    end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
    log.close
  end
end
