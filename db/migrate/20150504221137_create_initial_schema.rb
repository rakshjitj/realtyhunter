class CreateInitialSchema < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.string :logo_id, :string
      t.timestamps null: false
      t.references :offices, index: true
      t.references :users, index: true
      t.references :buildings, index: true
      #t.references :units, index: true
      # t.references :landlords, index: true
    end

    # TODO: code smell? companies, offices, users

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
      t.timestamps null: false
    end
    add_index :users, :email, unique: true

    create_table :neighborhoods do |t|
      t.string :name
      t.string :borough

      t.timestamps null: false
    end

    create_table :buildings do |t|
      t.string :street_address
      t.string :zip
      t.string :private_notes
      t.belongs_to :company
      #t.belongs_to :landlord
      t.timestamps null: false
    end

    create_table :units do |t|
      t.string :building_unit
      t.integer :rent
      t.belongs_to :building
      #  this causes a problem with our MTI setup
      #t.timestamps null: false
    end

    create_table :residential_units do |t|
      t.integer :beds
      t.float :baths
    end

    create_table :commercial_units do |t|
      t.string :sq_footage
      t.string :floor
      t.string :property_type
    end

    # create_table :landlords do |t|
    #   t.string :code
    #   t.string :private_notes
    #   t.string :shared_notes
    #   t.belongs_to :company
    #   t.references :buildings, index: true
    #   t.timestamps null: false
    # end

  end
end
