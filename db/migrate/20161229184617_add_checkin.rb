class AddCheckin < ActiveRecord::Migration
  def change
    create_table :checkins do |t|
      t.belongs_to :unit
      t.belongs_to :user
      t.timestamps
    end

    add_reference :units, :checkins
    add_reference :users, :checkins
  end
end
