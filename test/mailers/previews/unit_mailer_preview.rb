# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UnitMailerPreview < ActionMailer::Preview

  def inaccuracy_reported
    listing = ResidentialListing.all.first
    reporter = User.where(email: 'rbujans@myspacenyc.com').first
    UnitMailer.inaccuracy_reported(listing.id, reporter.id, 'This apartment is dirty!', true)
  end

  def send_residential_listings
    source_agent = User.where(email: 'rbujans@myspacenyc.com').first
    listing_ids = ResidentialListing.joins(:unit).where('units.archived = false')
        .limit(3)
        .select('listing_id')
        .pluck(:listing_id)
    listings = ResidentialListing.listings_by_id(source_agent, listing_ids)
    images = ResidentialListing.get_images(listings)

    UnitMailer.send_residential_listings(source_agent.id, listing_ids,
      ['look.away@gmail.com'],
      'Checkout these great listings',
      'amazing listings just for you')
  end

  def send_commercial_listings
    source_agent = User.where(email: 'rbujans@myspacenyc.com').first
    listing_ids = CommercialListing.joins(:unit).where('units.archived = false')
        .limit(3)
        .select('listing_id')
        .pluck(:listing_id)
    listings = CommercialListing.listings_by_id(source_agent, listing_ids)
    images = CommercialListing.get_images(listings)

    UnitMailer.send_commercial_listings(source_agent, listings, images,
      ['look.away@gmail.com'],
      'Checkout these great listings',
      'amazing listings just for you')
  end

  def send_residential_csv
    source_agent = User.where(email: 'rbujans@myspacenyc.com').first
    UnitMailer.send_residential_csv(source_agent.id)
  end

end
