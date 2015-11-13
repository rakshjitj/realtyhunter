class ChangeAnnouncementFields < ActiveRecord::Migration
  def change
  	remove_column :announcements, :audience, :integer
  	remove_column :announcements, :canned_response, :string
  	remove_column :announcements, :unit_id, :integer
  	add_column :announcements, :category, :integer
  	remove_reference :units, :announcement
  end
end
