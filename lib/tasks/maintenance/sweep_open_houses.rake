namespace :maintenance do
  desc "removes expired open houses"
  task :sweep_open_houses => :environment do
    log = ActiveSupport::Logger.new('log/sweep_open_houses.log')
    start_time = Time.now

    company = Company.find_by(name: 'MyspaceNYC')

    puts "Removing expired open houses..."
    log.info "Removing expired open houses..."

    # can use delete_all because there are no dependent callbacks/objects depending on open houses
    open_houses = OpenHouse.where("open_houses.day < ?", 0.day.ago)
    open_houses.delete_all

    puts "Done!\n"
    log.info "Done!\n"
    end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
    log.close
  end
end
