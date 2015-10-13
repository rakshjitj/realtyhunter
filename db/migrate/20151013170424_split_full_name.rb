class SplitFullName < ActiveRecord::Migration
  def change
  	remove_column :roomsharing_applications, :full_name, :string
  	add_column :roomsharing_applications, :f_name, :string
  	add_column :roomsharing_applications, :l_name, :string
  	remove_column :roomsharing_applications, :listing_id, :string
  	add_column :roomsharing_applications, :listing_address, :string
  	add_column :roomsharing_applications, :listing_unit, :string
  	remove_column :roomsharing_applications, :bank_name, :string
  	remove_column :roomsharing_applications, :checking_acct_no, :string
  	remove_column :roomsharing_applications, :savings_acct_no, :string
  	remove_column :roomsharing_applications, :relative_name, :string
  	remove_column :roomsharing_applications, :relative_address, :string
  	remove_column :roomsharing_applications, :relative_phone, :string	
  end
end
