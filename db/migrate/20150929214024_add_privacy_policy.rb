class AddPrivacyPolicy < ActiveRecord::Migration
  def change
  	add_column :companies, :privacy_policy, :text
  	add_column :companies, :terms_conditions, :text
  end
end
