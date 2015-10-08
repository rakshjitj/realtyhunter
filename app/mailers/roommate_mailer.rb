class RoommateMailer < ApplicationMailer
	def send_message(source_agent, recipients, sub, msg)
    @source_agent = source_agent
    @message = msg
    mail to: recipients, subject: sub, from: @source_agent.email
  end
end
