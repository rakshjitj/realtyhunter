class CreateTenantInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :tenant_infos do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.integer :residential_listing_id
      t.timestamps
    end
  end
end
