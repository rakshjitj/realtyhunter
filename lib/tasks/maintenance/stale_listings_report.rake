namespace :maintenance do
  desc "Gets all listings with a modified date > 2 weeks ago"
  task :stale_listings_report => :environment do
    log = ActiveSupport::Logger.new('log/stale_listings.log')
    start_time = Time.now

    company = Company.find_by(name: 'MyspaceNYC')

    puts "Getting stale listings..."
    log.info "Getting stale listings..."

    @units = ResidentialListing.joins(unit: :building)
      .where('units.archived = false')
      .where("units.status = ?", Unit.statuses['active'])
      .order('buildings.street_number')

    results = []
    @units.each {|u|
      if u.updated_at < 2.days.ago && u.description.blank?
        unit_address = u.street_address_and_unit
        results << unit_address + " [#{u.updated_at}]"
      end
    }

    puts "Found #{results.count} results:"
    puts "\n" + results.join("\n")

    managers = ['info@myspacenyc.com', 'smullahy@myspacenyc.com']
    UnitMailer.send_stale_listings_report(managers, results).deliver
    puts "Email sent to #{managers.inspect}"
    log.info "Email sent to #{managers.inspect}"

    puts "Done!\n"
    log.info "Done!\n"
    end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
    log.close
  end
end
