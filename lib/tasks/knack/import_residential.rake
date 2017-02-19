namespace :knack do
  desc "import residential ids from knack"
  task :import_residential => :environment do
    include KnackInterface

    log = ActiveSupport::Logger.new('log/import_residential.log')
    start_time = Time.now

    puts "Importing residential from knack..."
    log.info "Importing residential from knack..."

    gli = GetResidentialListingIds
    gli.perform

    puts "Done!\n"
    log.info "Done!\n"
    end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
    log.close
  end
end
