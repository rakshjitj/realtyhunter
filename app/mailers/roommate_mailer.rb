class RoommateMailer < ApplicationMailer
	def send_message(source_agent_id, recipients, sub, msg, roommate_ids)
    @source_agent = User.where(id: source_agent_id).first
    @message = msg
    @roommates = Roommate.joins('left join neighborhoods on roommates.neighborhood_id = neighborhoods.id')
      .select(
    	  'roommates.id', 'roommates.describe_yourself',
    	  'roommates.upload_picture_of_yourself',
    	  'roommates.name', 'roommates.phone_number', 'roommates.email',
    	  'neighborhoods.name as neighborhood_name',
    	  'roommates.monthly_budget', 'roommates.move_in_date', 'roommates.dogs_allowed',
    	  'roommates.cats_allowed', 'roommates.created_at as submitted_date',
    	  'roommates.archived')
      .where(id: roommate_ids)
    mail to: recipients, reply_to: 'no-reply@myspacenyc.com', subject: sub, tag: 'roommates', track_opens:'true'
  end
end
