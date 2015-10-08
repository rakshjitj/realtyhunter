class RemoveRoommateImg < ActiveRecord::Migration
  def change
  	remove_belongs_to :images, :roommate
  end
end
