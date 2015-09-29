class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@realtyhunter.com"
  helper ApplicationHelper
  helper ResidentialUnitsHelper
  layout 'mailer'
end
