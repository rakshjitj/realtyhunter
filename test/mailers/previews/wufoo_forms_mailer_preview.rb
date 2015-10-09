# Preview all emails at http://localhost:3000/rails/mailers/wufoo_forms_mailer
class WufooFormsMailerPreview < ActionMailer::Preview
  def send_listings
    source_agent = User.where(email: 'rbujans@myspacenyc.com').first
    
    WufooFormsMailer.send_message(source_agent, 
      ['look.away@gmail.com'], 
      'Roommsharing Updates', 
      "Hey guys, we've matched you all with the perfect apartment!")
  end
end
