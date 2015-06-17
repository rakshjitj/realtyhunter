class AddImagesToBuilding < ActiveRecord::Migration
  def self.up
    add_attachment :buildings, :avatar
  end

  def self.down
    remove_attachment :buildings, :avatar
  end
end
