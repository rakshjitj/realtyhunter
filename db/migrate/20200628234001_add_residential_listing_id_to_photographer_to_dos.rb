class AddResidentialListingIdToPhotographerToDos < ActiveRecord::Migration[5.0]
  def change
  	add_column :photo_grapher_to_dos, :residential_listing_id, :integer
  end
end
