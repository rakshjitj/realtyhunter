class CreatePhotoGrapherToDos < ActiveRecord::Migration[5.0]
  def change
    create_table :photo_grapher_to_dos do |t|
      t.boolean :level_of_urgency, default: false
      t.text :notes
      t.integer :sort_urgency
      t.boolean :send_todo, default: false

      t.timestamps
    end
  end
end
