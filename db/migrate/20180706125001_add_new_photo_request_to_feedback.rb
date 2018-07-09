class AddNewPhotoRequestToFeedback < ActiveRecord::Migration[5.0]
  def change
  	add_column :feedbacks, :new_photos_request, :boolean
  end
end
