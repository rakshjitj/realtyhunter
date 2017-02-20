# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class BuildingMailerPreview < ActionMailer::Preview

  def send_creation_notification
    building = Building.all.last
    # reporter = User.where(email: 'rbujans@myspacenyc.com').first
    BuildingMailer.send_creation_notification(building.id)
  end

end
