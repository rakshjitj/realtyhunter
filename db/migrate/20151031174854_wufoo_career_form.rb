class WufooCareerForm < ActiveRecord::Migration
  def change
  	create_table :wufoo_career_forms do |t|
			t.string :name
			t.string :phone_number
			t.string :email
			t.string :how_did_you_hear_about_us
			t.string :what_neighborhood_do_you_live_in
			t.string :licensed_agent
			t.string :resume_upload
			t.string :created_by
			t.string :internal_notes
			t.belongs_to :company
			t.boolean :archived, default: false
			t.timestamps null: false
  	end

  	change_table :companies do |t|
		  t.references :wufoo_career_forms, index: true
		end
		
  end
end
