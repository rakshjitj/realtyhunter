class AddEmailAndSmsNotificationToMediaDashboardResidentialListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :tenant_email_date, :date
  	add_column :residential_listings, :tenant_sms_date, :date
  end
end
