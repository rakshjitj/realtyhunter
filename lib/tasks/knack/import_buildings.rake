namespace :knack do
  desc "import buildings ids from knack"
  task :import_buildings => :environment do
    include KnackInterface

    log = ActiveSupport::Logger.new('log/import_buildings.log')
    start_time = Time.now

    puts "Importing buildings from knack..."
    log.info "Importing buildings from knack..."

    gbi = GetBuildingIds
    gbi.perform

    puts "Done!\n"
    log.info "Done!\n"
    end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
    log.close
  end
end
