class ApplicationMailer < ActionMailer::Base
  default from: "info@realtyhunter.com"
  helper ApplicationHelper
  helper ResidentialListingsHelper
  layout 'mailer'
end
