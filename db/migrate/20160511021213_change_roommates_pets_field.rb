class ChangeRoommatesPetsField < ActiveRecord::Migration
  def change
    add_column :roommates, :do_you_have_pets, :string
  end
end
