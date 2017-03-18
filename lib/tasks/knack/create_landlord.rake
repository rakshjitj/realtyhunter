namespace :knack do
  desc "export landlord to knack"
  task :create_landlord => :environment do
    include KnackInterface

    log = ActiveSupport::Logger.new('log/knack_create_landlord.log')
    start_time = Time.now

    puts "Sending landlord to knack..."
    log.info "Sending landlord to knack..."

    landlord = Landlord.where(code: '101 Bedford').first
    cl = CreateLandlord
    cl.perform(landlord.id)
    # Resque.enqueue(CreateLandlord, landlord.id)

    puts "Done!\n"
    log.info "Done!\n"
    end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
    log.close
  end
end
