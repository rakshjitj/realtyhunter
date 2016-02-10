class AddNewFieldsToResidentialListings < ActiveRecord::Migration
  def change
    add_column :residential_listings, :floor_number, :integer
    add_column :residential_listings, :total_room_count, :integer
    add_column :residential_listings, :condition, :string
    add_column :residential_listings, :showing_instruction, :string
    add_column :residential_listings, :commission_amount, :decimal
    add_column :residential_listings, :cyof, :boolean, default: false
    add_column :residential_listings, :rented_date, :date
    add_column :residential_listings, :rlsny, :boolean, default: false
    add_column :residential_listings, :share_with_brokers, :boolean, default: false
  end
end
