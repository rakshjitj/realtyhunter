class AddAnnouncementsTable < ActiveRecord::Migration
  def change
  	create_table :announcements do |t|
  		t.belongs_to :unit
  		t.integer :audience, default: 0
  		t.string :canned_response
  		t.string :note
      t.boolean :was_broadcast, default: false
      t.timestamps null: false
    end

    add_reference :units, :announcement, index: true
  end
end
