class AddNotificationToForms < ActiveRecord::Migration
  def change
  	# keeps track of whether a new roommate has been
  	# viewed or not
  	add_column :wufoo_contact_us_forms, :read, :boolean, default: false
  	add_column :wufoo_partner_forms, :read, :boolean, default: false
  	add_column :wufoo_career_forms, :read, :boolean, default: false
  end
end
