  class CreateInitialSchema < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.string :logo_id, :string
      t.timestamps null: false
      t.references :offices, index: true
      t.references :users, index: true
      t.references :buildings, index: true
      t.references :landlords, index: true
    end

    create_table :offices do |t|
      t.string :name
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zipcode
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
      t.references :buildings, index: true
      t.timestamps null: false
    end
    add_index :users, :email, unique: true

    create_table :neighborhoods do |t|
      t.string :name
      t.string :borough
      t.string :city
      t.string :state
      t.timestamps null: false
      t.references :buildings, index: true
    end

    create_table :buildings do |t|
      t.string :formatted_street_address
      t.string :street_number
      t.string :route
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
      # default agent
      # features
      t.timestamps null: false
    end

    create_table :units do |t|
      t.string :building_unit
      t.integer :rent
      t.timestamp :available_by
      t.string :access_info
      t.integer :status, default: 0
      #t.string :listing_type
      t.string :open_house
      t.float :weeks_free_offered
      t.belongs_to :building
      # primary agent
      # updated_by
      #  this causes a problem with our MTI setup
      #t.timestamps null: false
    end

    create_table :residential_units do |t|
      t.integer :beds
      t.float :baths
      t.string :notes
      t.integer :lease_duration, default: 0
    end

    create_table :commercial_units do |t|
      t.string :sq_footage
      t.string :floor
      t.string :property_type
      t.string :property_sub_type
      t.string :listing_id
      t.string :building_size
      t.string :description
    end

    create_table :landlords do |t|
      t.string :code
      t.string :name
      t.string :phone
      t.string :mobile
      t.string :fax
      t.string :email
      t.string :website
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zipcode
      t.text :notes
      t.integer :listing_agent_percentage
      t.integer :months_required
      t.string :pet_policy
      t.string :management_info

      t.belongs_to :company
      t.references :buildings, index: true
      t.timestamps null: false
    end

  end
end
