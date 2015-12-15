class AddStateToRoommateApp < ActiveRecord::Migration
  def change
  	add_column :roomsharing_applications, :curr_state_abbrev, :string
  	add_column :roomsharing_applications, :prev_state_abbrev, :string
  end
end
