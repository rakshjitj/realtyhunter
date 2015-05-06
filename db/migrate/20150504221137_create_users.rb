class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :fname
      t.string :lname
      t.string :email
      t.string :password_digest
      t.string :remember_digest
      t.string :avatar_url
      t.text :bio
    end
    #add_index :users, :email, unique: true
  end
end
