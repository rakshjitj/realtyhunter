# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class LandlordMailerPreview < ActionMailer::Preview

  def send_creation_notification
    ll = Landlord.all.last
    LandlordMailer.send_creation_notification(ll.id)
  end

end
