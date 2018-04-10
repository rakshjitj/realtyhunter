class CreateRooms < ActiveRecord::Migration[5.0]
  def change
    create_table :rooms do |t|
      t.string :name
      t.integer :rent
      t.integer :status
      t.string :description

      t.timestamps
    end
  end
end
