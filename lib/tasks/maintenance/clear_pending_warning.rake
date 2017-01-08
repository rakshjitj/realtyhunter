namespace :maintenance do
  desc "warning about flips stale pending residential listings"
  task :clear_pending_warning => :environment do
    log = ActiveSupport::Logger.new('log/change_passwords.log')
    start_time = Time.now

    puts "Getting stale pending residential listings..."
    log.info "Getting stale pending residential listings..."

    # company = Company.find_by(name: 'MyspaceNYC')

    stale_listings = ResidentialListing.joins(:unit)
        .where('archived = false')
        .where('units.status = ?', Unit.statuses['pending'])
        .where('residential_listings.updated_at < ?', 2.weeks.ago)
        .where('units.updated_at < ?', 2.weeks.ago)
        # .where('companies.id = ?', company.company_id)

    puts "Warning! These listings will be updated to off-status tomorrow. " +
        "Found #{stale_listings.count} results:"
    stale_listings = stale_listings.pluck(:id)
    puts "******* #{stale_listings.inspect}"

    managers = ['info@myspacenyc.com', 'rbujans@myspacenyc.com']
    UnitMailer.send_clear_pending_warning_report(managers, stale_listings).deliver
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
