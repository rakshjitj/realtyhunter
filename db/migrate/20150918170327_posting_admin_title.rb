class PostingAdminTitle < ActiveRecord::Migration
  def change
  	r = Role.find_or_create_by(name: "listings_manager")
  	r.save
  end
end
