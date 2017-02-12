namespace :knack do
  desc "import landlords ids from knack"
  task :import_landlords => :environment do
    include KnackInterface

    log = ActiveSupport::Logger.new('log/import_landlords.log')
    start_time = Time.now

    puts "Importing landlords from knack..."
    log.info "Importing landlords from knack..."

    gli = GetLandlordIds
    gli.perform

    puts "Done!\n"
    log.info "Done!\n"
    end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
    log.close
  end
end
