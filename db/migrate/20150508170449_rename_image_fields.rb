class RenameImageFields < ActiveRecord::Migration
  def change
  	remove_column :users, :avatar_key, :string
  	add_column :users, :avatar_id, :string
  end
end
