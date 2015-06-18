  class CreateInitialSchema < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.boolean :archived, default: false
      t.string :name
      t.string :logo_id, :string
      t.timestamps null: false
      t.references :offices, index: true
      t.references :users, index: true
      t.references :buildings, index: true
      t.references :landlords, index: true
      t.references :building_amenities, index: true
      t.references :rental_terms, index: true
      t.references :required_securities, index: true
      t.references :pet_policies, index: true
      t.references :residential_amenities, index: true
    end

    create_table :offices do |t|
      t.boolean :archived, default: false
      t.string :formatted_street_address
      t.string :street_number
      t.string :route
      t.string :sublocality
      t.string :administrative_area_level_2_short
      t.string :administrative_area_level_1_short
      t.string :postal_code
      t.string :neighborhood
      t.string :country_short
      t.string :lat
      t.string :lng
      t.string :place_id
      
      t.string :name
      t.string :telephone
      t.string :fax
      t.belongs_to :company
      t.references :users, index: true
      t.timestamps null: false
    end

    create_table :employee_titles do |t|
      t.string :name, unique: true
      t.references :users, index: true
      t.timestamps null: false
    end

    create_table :agent_types do |t|
      t.string :name, unique: true
      t.timestamps null: false
    end

    create_table :users do |t|
      t.boolean :archived, default: false
      t.string :auth_token
      t.string :name
      t.string :email
      t.string :phone_number
      t.string :mobile_phone_number
      t.string :password_digest
      t.string :remember_digest
      t.text   :bio
      t.string :activation_digest
      t.boolean :activated, default: false
      t.datetime :activated_at
      t.string :approval_digest
      t.boolean :approved, default: false
      t.datetime :approved_at
      t.string   :reset_digest
      t.datetime :reset_sent_at
      t.belongs_to :company
      t.belongs_to :office
      t.references :employee_title, index: true
      t.references :manager, index: true
      t.references :units, index: true # primary agent
      t.timestamps null: false
    end
    add_index :users, :email, unique: true

    create_table :neighborhoods do |t|
      t.boolean :archived, default: false
      t.string :name
      t.string :borough
      t.string :city
      t.string :state
      t.timestamps null: false
      t.references :buildings, index: true
    end

    create_table :landlords do |t|
      t.boolean :archived, default: false
      t.string :formatted_street_address
      t.string :street_number
      t.string :route
      t.string :sublocality
      t.string :administrative_area_level_2_short
      t.string :administrative_area_level_1_short
      t.string :postal_code
      t.string :neighborhood
      t.string :country_short
      t.string :lat
      t.string :lng
      t.string :place_id

      t.string :code
      t.string :name
      t.string :office_phone
      t.string :mobile
      t.string :fax
      t.string :email
      t.string :website
      t.text :notes
      t.integer :listing_agent_percentage
      t.string :management_info
      t.belongs_to :required_security
      t.belongs_to :company
      t.references :buildings, index: true
      t.timestamps null: false
    end

    # uses paperclip to upload to S3
    create_table :images do |t|
      t.attachment :file
      # t.string :avatar_id # refile
      # t.string :avatar_key # refile
      t.integer :priority
      t.belongs_to :building
      t.belongs_to :unit
    end

    # TODO: pull address info into it's own table?
    create_table :buildings do |t|
      t.boolean :archived, default: false
      t.string :formatted_street_address
      t.string :street_number
      t.string :route
      t.string :intersection
      t.string :sublocality
      t.string :administrative_area_level_2_short
      t.string :administrative_area_level_1_short
      t.string :postal_code
      t.string :country_short
      t.string :lat
      t.string :lng
      t.string :place_id

      t.string :notes
      t.belongs_to :company
      t.belongs_to :landlord
      t.belongs_to :neighborhood
      t.belongs_to :user
      t.references :images, index: true
      t.timestamps null: false
    end

    create_table :units do |t|
      t.boolean :archived, default: false
      t.integer :listing_id
      t.string :building_unit
      t.integer :rent # always stored as monthly gross rate
      t.timestamp :available_by
      t.string :access_info
      t.integer :status, default: 0
      t.string :open_house
      t.integer :weeks_free_offered, default: 0
      t.belongs_to :building
      t.belongs_to :user # primary agent
      t.references :images, index: true
      t.timestamps null: false
    end

    create_table :residential_units do |t|
      t.integer :beds
      t.float   :baths
      t.string  :notes
      t.integer :lease_duration, default: 0
      t.integer :op_fee_percentage
      t.integer :tp_fee_percentage
      t.belongs_to :pet_policy
    end

    create_table :commercial_units do |t|
      t.integer :sq_footage
      t.integer :floor
      t.integer :building_size
      t.boolean :build_to_suit, default: false
      t.integer :minimum_divisble
      t.integer :maximum_contiguous
      t.integer :lease_type
      t.boolean :is_sublease, default: false
      t.string  :property_description
      t.string  :location_description
      t.integer :construction_status, default: 0
      t.integer :no_parking_spaces
      t.integer :pct_procurement_fee
      t.integer :lease_term_months # different time frames than residential
      t.boolean :rate_is_negotiable
      t.integer :total_lot_size
      t.belongs_to :commercial_property_type
    end

    create_table :building_amenities do |t|
      t.string :name
      t.belongs_to :company
      t.timestamps null: false
    end

    create_table :building_amenities_buildings, id: false do |t|
      t.belongs_to :building
      t.belongs_to :building_amenity
    end

    create_table :rental_terms do |t|
      t.string :name
      t.belongs_to :company
      t.timestamps null: false
    end

    create_table :buildings_rental_terms, id: false do |t|
      t.belongs_to :building
      t.belongs_to :rental_term
    end

    create_table :required_securities do |t|
      t.string :name
      t.belongs_to :company
      t.references :landlords, index: true
      t.timestamps null: false
    end

    create_table :pet_policies do |t|
      t.string :name
      t.belongs_to :company
      t.references :residential_units, index: true
      t.timestamps null: false
    end

    create_table :residential_amenities do |t|
      t.string :name
      t.belongs_to :company
      t.timestamps null: false
    end

    # common prefix "residential" gets factored out
    create_table :residential_amenities_units, id: false do |t|
      t.belongs_to :residential_unit
      t.belongs_to :residential_amenity
    end

    create_table :commercial_property_types do |t|
      t.belongs_to :company
      t.string :property_type
      t.string :property_sub_type
      t.timestamps null: false
    end
  end
end
