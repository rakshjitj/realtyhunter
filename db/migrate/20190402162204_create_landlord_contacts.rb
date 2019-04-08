class CreateLandlordContacts < ActiveRecord::Migration[5.0]
  def change
    create_table :landlord_contacts do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :position
      t.integer :landlord_id

      t.timestamps
    end
  end
end
