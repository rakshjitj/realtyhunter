class ChangeDefaultPhotoStatusCompleteToPhotoGrapherToDos < ActiveRecord::Migration[5.0]
  def change
  	change_column_default(:photo_grapher_to_dos, :completed, nil)
  end
end
