class AddUserIdAndPhotoStatusUpdateDate < ActiveRecord::Migration[5.0]
  def change
  	add_column :photo_grapher_to_dos, :user_id, :integer
  	add_column :photo_grapher_to_dos, :photo_status_update_date, :date 
  end
end
