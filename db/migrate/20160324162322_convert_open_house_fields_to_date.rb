
class ConvertOpenHouseFieldsToDate < ActiveRecord::Migration
  def change
    remove_column :units, :open_house, :string
    remove_column :units, :oh_exclusive, :boolean

    remove_column :residential_listings, :open_house_mon, :boolean, default: false
    remove_column :residential_listings, :open_house_mon_from, :string
    remove_column :residential_listings, :open_house_mon_to, :string
    remove_column :residential_listings, :open_house_tue, :boolean, default: false
    remove_column :residential_listings, :open_house_tue_from, :string
    remove_column :residential_listings, :open_house_tue_to, :string
    remove_column :residential_listings, :open_house_wed, :boolean, default: false
    remove_column :residential_listings, :open_house_wed_from, :string
    remove_column :residential_listings, :open_house_wed_to, :string
    remove_column :residential_listings, :open_house_thu, :boolean, default: false
    remove_column :residential_listings, :open_house_thu_from, :string
    remove_column :residential_listings, :open_house_thu_to, :string
    remove_column :residential_listings, :open_house_fri, :boolean, default: false
    remove_column :residential_listings, :open_house_fri_from, :string
    remove_column :residential_listings, :open_house_fri_to, :string
    remove_column :residential_listings, :open_house_sat, :boolean, default: false
    remove_column :residential_listings, :open_house_sat_from, :string
    remove_column :residential_listings, :open_house_sat_to, :string
    remove_column :residential_listings, :open_house_sun, :boolean, default: false
    remove_column :residential_listings, :open_house_sun_from, :string
    remove_column :residential_listings, :open_house_sun_to, :string

    create_table :open_houses do |t|
      t.time :start_time
      t.time :end_time
      t.date :day
      t.references :unit, index: true
      t.timestamps null: false
    end
    add_reference :units, :open_houses, index: true
  end
end
