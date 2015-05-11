class CreateInitialSchema < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.string :logo_id, :string
      t.timestamps null: false
    end

    create_table :offices do |t|
      t.string :name
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :telephone
      t.string :fax

      t.timestamps null: false
    end

    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :phone_number
      t.string :mobile_phone_number
      t.string :password_digest
      t.string :remember_digest
      t.string :avatar_key
      t.text   :bio
      t.string :activation_digest
      t.boolean :activated, default: false
      t.datetime :activated_at
      t.string   :reset_digest
      t.datetime :reset_sent_at
    end
    add_index :users, :email, unique: true
  end
end
