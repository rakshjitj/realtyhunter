class AddOpenHouseFieldsToResidentialListings < ActiveRecord::Migration
  def change
    add_column :residential_listings, :open_house_mon, :boolean, default: false
    add_column :residential_listings, :open_house_mon_from, :string
    add_column :residential_listings, :open_house_mon_to, :string
    add_column :residential_listings, :open_house_tue, :boolean, default: false
    add_column :residential_listings, :open_house_tue_from, :string
    add_column :residential_listings, :open_house_tue_to, :string
    add_column :residential_listings, :open_house_wed, :boolean, default: false
    add_column :residential_listings, :open_house_wed_from, :string
    add_column :residential_listings, :open_house_wed_to, :string
    add_column :residential_listings, :open_house_thu, :boolean, default: false
    add_column :residential_listings, :open_house_thu_from, :string
    add_column :residential_listings, :open_house_thu_to, :string
    add_column :residential_listings, :open_house_fri, :boolean, default: false
    add_column :residential_listings, :open_house_fri_from, :string
    add_column :residential_listings, :open_house_fri_to, :string
    add_column :residential_listings, :open_house_sat, :boolean, default: false
    add_column :residential_listings, :open_house_sat_from, :string
    add_column :residential_listings, :open_house_sat_to, :string
    add_column :residential_listings, :open_house_sun, :boolean, default: false
    add_column :residential_listings, :open_house_sun_from, :string
    add_column :residential_listings, :open_house_sun_to, :string
  end
end
