class AddRebnyFields < ActiveRecord::Migration
  def change
    add_column :residential_listings, :floor, :integer
    add_column :residential_listings, :total_room_count, :integer
    add_column :residential_listings, :condition, :string
    add_column :residential_listings, :showing_instruction, :string
    add_column :residential_listings, :commission_amount, :decimal
    add_column :residential_listings, :cyof, :boolean, default: false
    add_column :residential_listings, :rented_date, :date
    add_column :residential_listings, :rlsny, :boolean, default: false
    add_column :residential_listings, :share_with_brokers, :boolean, default: false

    add_column :sales_listings, :floor, :integer
    add_column :sales_listings, :total_room_count, :integer
    add_column :sales_listings, :condition, :string
    add_column :sales_listings, :showing_instruction, :string
    add_column :sales_listings, :commission_amount, :decimal
    add_column :sales_listings, :cyof, :boolean, default: false
    add_column :sales_listings, :rented_date, :date
    add_column :sales_listings, :rlsny, :boolean, default: false
    add_column :sales_listings, :share_with_brokers, :boolean, default: false
  end
end
