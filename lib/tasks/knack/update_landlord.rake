namespace :knack do
  desc "update landlord in knack"
  task :update_landlord => :environment do
    include KnackInterface

    log = ActiveSupport::Logger.new('log/knack_update_landlord.log')
    start_time = Time.now

    puts "Sending updated landlord to knack..."
    log.info "Sending updated landlord to knack..."

    landlord = Landlord.where(code: '101 Bedford').first
    cl = UpdateLandlord
    cl.perform(landlord.id)
    #Resque.enqueue(UpdateLandlord, landlord.id)

    puts "Done!\n"
    log.info "Done!\n"
    end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
    log.close
  end
end
