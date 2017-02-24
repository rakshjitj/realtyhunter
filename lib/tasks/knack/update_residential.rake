namespace :knack do
  desc "update residential listing in knack"
  task :update_residential => :environment do
    include KnackInterface

    log = ActiveSupport::Logger.new('log/knack_update_residential_listing.log')
    start_time = Time.now

    puts "Sending updated residential listing to knack..."
    log.info "Sending updated residential listing to knack..."

    id = 13706
    is_now_active = true
    r = ResidentialListing.find(id)
    # clear out old data
    # r.update_attribute(:knack_id, nil)
    # r.unit.building.update_attribute(:knack_id, nil)
    # r.unit.building.landlord.update_attribute(:knack_id, nil)
    # re-add it to knack
    cr = UpdateResidentialListing
    cr.perform(id, is_now_active) # 173 Herkimer

    puts "Done!\n"
    log.info "Done!\n"
    end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
    log.close
  end
end
