class CreateDeals < ActiveRecord::Migration
  def change
    create_table :deals do |t|
    	t.string :price
    	t.string :client
    	t.string :lease_term
    	t.datetime :lease_start_date
    	t.datetime :lease_expiration_date
    	t.datetime :closed_date
    	t.datetime :move_in_date
    	t.string :commission
    	t.string :deal_notes
    	t.string :listing_type
    	t.boolean :is_sale_deal
        t.boolean :archived, default: false
    	t.belongs_to :unit
    	t.belongs_to :user # closing_agents
        t.references :clients
    	t.timestamps	
    end

    create_table :clients do |t|
        t.string  :name
        t.datetime :date_of_birth
        t.string  :phone
        t.string  :email
        t.boolean :archived, default: false
        t.belongs_to :deal
        t.timestamps
    end

    add_reference :units, :deals
    add_reference :users, :deals
  end
end
