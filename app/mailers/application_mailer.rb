class ApplicationMailer < ActionMailer::Base
  include Resque::Mailer

  default from: "info@myspacenyc.com"
  helper ApplicationHelper
  helper ResidentialListingsHelper
  layout 'mailer'
end
