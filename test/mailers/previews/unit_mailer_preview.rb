# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UnitMailerPreview < ActionMailer::Preview

  def send_residential_listings
    source_agent = User.where(email: 'rbujans@myspacenyc.com').first
    listings = ResidentialListing.listings_by_id(source_agent, [9825715, 287337, 228125])
    images = ResidentialListing.get_images(listings)

    UnitMailer.send_residential_listings(source_agent, listings, images,
      ['look.away@gmail.com'],
      'Checkout these great listings',
      'amazing listings just for you')
  end

  def send_commercial_listings
    source_agent = User.where(email: 'rbujans@myspacenyc.com').first
    listings = CommercialListing.listings_by_id(source_agent, [9825715, 287337, 228125])
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
