namespace :maintenance do
  desc "Gets all listings set to force syndicate"
  task :forced_syndication_report => :environment do
    log = ActiveSupport::Logger.new('log/stale_listings.log')
    start_time = Time.now

    company = Company.find_by(name: 'MyspaceNYC')

    puts "Getting force syndicated listings..."
    log.info "Getting force syndicated listings..."

    @units = ResidentialListing.joins(unit: :building)
      .where('units.archived = false')
      .where('units.syndication_status = ?', Unit.syndication_statuses['Force syndicate'])
      .where("units.status = ?", Unit.statuses['active'])
      .order('buildings.street_number')

    results = []
    @units.each {|u|
      results << u.street_address_and_unit
    }

    puts "Found #{results.count} results:"
    puts "\n" + results.join("\n")

    managers = ['rbujans@myspacenyc.com']
    UnitMailer.send_forced_syndication_report(managers, results).deliver
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
