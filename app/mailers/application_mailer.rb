class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@realtyhunter.com"
  helper ApplicationHelper
  helper ResidentialListingsHelper
  layout 'mailer'
end
