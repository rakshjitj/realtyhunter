# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UnitMailerPreview < ActionMailer::Preview
  def send_listings#(source_agent, listings, images, recipients, sub, msg)
    source_agent = User.where(email: 'rbujans@myspacenyc.com').first
    listings = ResidentialListing.listings_by_id(source_agent, [9825715, 287337, 228125])
    images = ResidentialListing.get_images(listings)

    UnitMailer.send_listings(source_agent, listings, images, 
      ['look.away@gmail.com'], 
      'Checkout these great listings', 
      'amazing listings just for you')
    
  end

end
