class AddWhatIsNeededAndChangeLevelOfUrgencyToPhotoGrapherToDos < ActiveRecord::Migration[5.0]
  def change
  	add_column :photo_grapher_to_dos, :what_is_needed, :text
  	change_column :photo_grapher_to_dos, :level_of_urgency, :string
  	change_column_default(:photo_grapher_to_dos, :level_of_urgency, nil)
  end
end
