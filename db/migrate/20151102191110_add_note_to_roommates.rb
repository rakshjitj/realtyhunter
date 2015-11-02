class AddNoteToRoommates < ActiveRecord::Migration
  def change
  	add_column :roommates, :internal_notes, :string
  end
end
