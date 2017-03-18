namespace :knack do
  desc "export building to knack"
  task :find_dupe_ids => :environment do
    include KnackInterface

    log = ActiveSupport::Logger.new('log/find_dupe_ids.log')
    start_time = Time.now

    puts "Looking for dupe knack_ids in our system..."
    log.info "Looking for dupe knack_ids in our system..."

    knack_ids = {}
    listings = ResidentialListing.where.not(knack_id: nil)
    listings.each do |l|
        if knack_ids.key? l.knack_id
            knack_ids[l.knack_id] = knack_ids[l.knack_id] + 1
        else
            knack_ids[l.knack_id] = 1
        end
    end

    knack_ids.each do |k,v|
        if v > 1
          puts "#{k} - #{v}"
          log.info  "#{k} - #{v}"
        end
    end


    puts "Done!\n"
    log.info "Done!\n"
    end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
    log.close
  end
end
