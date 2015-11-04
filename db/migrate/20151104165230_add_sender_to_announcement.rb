class AddSenderToAnnouncement < ActiveRecord::Migration
  def change
    add_reference :users, :announcements, index: true
  	add_reference :announcements, :user
  end
end
