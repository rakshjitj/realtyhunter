class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :fname
      t.string :lname
      t.string :email
      t.string :phone_number
      t.string :mobile_phone_number
      t.string :password_digest
      t.string :remember_digest
      t.string :avatar_url
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
