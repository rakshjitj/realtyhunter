namespace :knack do
  desc "detect duplicate buildings in knack"
  task :find_dupe_buildings => :environment do
    include KnackInterface

    log = ActiveSupport::Logger.new('log/find_dupe_buildings.log')
    start_time = Time.now

    puts "Finding duplicate buildings in knack..."
    log.info "Finding duplicate buildings in knack..."

    fdb = FindDupeBuildings
    fdb.perform

    puts "Done!\n"
    log.info "Done!\n"
    end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
    log.close
  end
end
