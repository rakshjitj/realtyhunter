class ChangeDobToDateTime < ActiveRecord::Migration
  def change
  	remove_column :roomsharing_applications, :dob, :string
  	add_column :roomsharing_applications, :dob, :date
  end
end
