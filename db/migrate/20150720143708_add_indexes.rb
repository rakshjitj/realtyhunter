class AddIndexes < ActiveRecord::Migration
  def change
    # add indexes to improve search speed
    add_index :companies, :name
    add_index :users, :name
    add_index :landlords, :code
    add_index :buildings, :formatted_street_address
    add_index :buildings, :updated_at
    add_index :units, :status
    # TODO: how to add partial indexes?
    #add_index :units, :status_active, where: "status = 2"
    #add_index :units, :status_pending, where: "status = 1"
    #add_index :units, :status_off, where: "status = 0"
    add_index :units, :rent
    add_index :units, :updated_at
    add_index :residential_units, :beds
    add_index :residential_units, :baths
  end
end
