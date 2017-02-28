class LandlordMailer < ApplicationMailer
  def send_creation_notification(landlord_id)
    @landlord = Landlord.where(id: landlord_id).first
    mail to: ['uricohen646@gmail.com', 'rbujans@myspacenyc.com'],
      subject: "New landlord created: #{@landlord.code}",
        reply_to: 'uricohen646@gmail.com',
        tag: 'landlord_created',
        track_opens:'true'
  end
end
