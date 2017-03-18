namespace :knack do
  desc "export building to knack"
  task :create_building => :environment do
    include KnackInterface

    log = ActiveSupport::Logger.new('log/create_building.log')
    start_time = Time.now

    puts "Sending building to knack..."
    log.info "Sending building to knack..."

    building = Building.where(id: 3631).first
    # cb = CreateBuilding
    # cb.perform(3631) # 173 Herkimer
    Resque.enqueue(CreateBuilding, building.id)

    puts "Done!\n"
    log.info "Done!\n"
    end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
    log.close
  end
end
