class AddPublicUrLs < ActiveRecord::Migration
  def change
  	add_column :units, :public_url, :string
  	add_column :users, :public_url, :string

  	# update our existing data
  	company = Company.find_by(name: 'MyspaceNYC')

		units = Unit.unarchived.where("buildings.company_id = ?", company.id).joins(building: :company)
		units.each do |unit|
			unit.update(public_url: "http://myspacenyc.com/listing/MYSPACENYC-#{unit.listing_id}")
		end

		users = User.unarchived.where(company_id: company.id).joins(:company)
		users.each do |user|
	    email_md5 = Digest::MD5.hexdigest(user.email)
			user.update(public_url: "http://myspacenyc.com/agent/AGENT-#{email_md5}")
		end

  end
end
