class AddStreeteasyEmailAndStreeteasyMobileToUsers < ActiveRecord::Migration[5.0]
  def change
  	add_column :users, :streeteasy_email, :string
  	add_column :users, :streeteasy_mobile_number, :string
  end
end
