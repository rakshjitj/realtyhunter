class ApplicationMailer < ActionMailer::Base
  default from: "info@myspacenyc.com"
  helper ApplicationHelper
  helper ResidentialListingsHelper
  layout 'mailer'
end
