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
            knack_ids[l.knack_id] << {
              id: l.id,
              address: l.street_address_and_unit
            }
        else
            knack_ids[l.knack_id] = [{
              id: l.id,
              address: l.street_address_and_unit
            }]
        end
    end

    knack_ids.each do |knack_id, list|
        if list.count > 1
          list.each do |item|
            puts "Address:#{item[:address]} ID:#{item[:id]} Knack ID:#{knack_id}"
            log.info "Address:#{item[:address]} ID:#{item[:id]} Knack ID:#{knack_id}"
          end
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
