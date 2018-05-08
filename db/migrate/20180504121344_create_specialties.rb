class CreateSpecialties < ActiveRecord::Migration[5.0]
  def change
    create_table :specialties do |t|
      t.string :name
      t.integer :company_id

      t.timestamps
    end
    create_table :specialties_users, id: false do |t|
      t.belongs_to :user
      t.belongs_to :specialty
    end
  end
end
