class WufooFormsMailer < ApplicationMailer
	def send_message(source_agent_id, recipients, sub, msg)
    @source_agent = User.where(id: source_agent_id).first
    @message = msg
    mail to: recipients, subject: sub, from: @source_agent.email,
        tag: 'wufoo', track_opens:'true'
  end
end
