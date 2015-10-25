class AddWaterfall < ActiveRecord::Migration
  def change
  	create_table :user_waterfalls do |t|
      t.belongs_to :parent_agent
      t.belongs_to :child_agent
      #t.references :users, index: true
      #t.boolean :is_senior
      # employees who still have their license parked with our company
      # (even if not actively working, on vacation, etc) earn a higher rate
      # than those who don't
      #t.boolean :is_here
      # can be 1/2/3
      t.integer :level 
      t.float :rate
      t.boolean :archived, default: false
      t.timestamps null: false
    end
  end
end
