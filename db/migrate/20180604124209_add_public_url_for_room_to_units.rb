class AddPublicUrlForRoomToUnits < ActiveRecord::Migration[5.0]
  def change
  	add_column :units, :public_url_for_room, :string
  end
end
