# Preview all emails at http://localhost:3000/rails/mailers
class RoomateMailerPreview < ActionMailer::Preview
  def send_listings

    source_agent = User.where(email: 'rbujans@myspacenyc.com').first
    roommate_ids = Roommate.all.limit(3).ids

    RoommateMailer.send_message(
    	source_agent,
      ['rbujans@myspacenyc.com'],
      'Check out these new roommates',
      "I think these guys would be a great match",
      roommate_ids)
  end
end
