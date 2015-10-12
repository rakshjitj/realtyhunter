class ApplicationTable < ActiveRecord::Migration
  def change
  	# reference this: https://www.rapidnyc.net/applicants/add_new
  	create_table :roomsharing_applications do |t|
  		# applicant information
			t.string :full_name
			t.string :ssn
			t.string :dob 
			t.string :cell_phone
			t.string :other_phone
			t.string :email
			t.string :describe_pets
			t.string :num_roommates
			t.string :relationship_to_roommates
			t.string :facebook_profile_url
			t.string :twitter_profile_url
			t.string :linkedin_profile_url
			# current address
			t.string :curr_street_address
			t.string :curr_apt_suite
			t.string :curr_city
			t.string :curr_zip
			t.string :curr_landlord_name
			t.string :curr_daytime_phone
			t.string :curr_evening_phone
			t.string :curr_rent_paid
			t.string :curr_tenancy_years
			t.string :curr_tenancy_months
			# prev address
			t.string :prev_street_address
			t.string :prev_apt_suite
			t.string :prev_city
			t.string :prev_zip
			t.string :prev_landlord_name
			t.string :prev_daytime_phone
			t.string :prev_evening_phone
			t.string :prev_rent_paid
			t.string :prev_tenancy_years
			t.string :prev_tenancy_months
			# current employment
			t.string :curr_annual_income
			t.string :curr_time_employed_years
			t.string :curr_time_employed_months
			t.string :curr_dates_employed
			#prev employment
			t.string :prev_annual_income
			t.string :prev_time_employed_years
			t.string :prev_time_employed_months
			t.string :prev_dates_employed
			# bank reference
			t.string :bank_name
			t.string :checking_acct_no
			t.string :savings_acct_no
			# nearest relative
			t.string :relative_name
			t.string :relative_address
			t.string :relative_phone
			# property information
			t.string :listing_id
			# agent
			t.string :agent_name
			# terms & agreements
			t.boolean :allow_background_authorization
			# true = "I have not physically seen the property and I understand that I have 3 days 
			#         to see the property, after which my deposit is not refundable unless my 
			#         application is denied."
			# false = "I have seen the property for which I will be leaving a deposit."
			t.boolean :is_sight_unseen
			t.boolean :has_renters_insurace
			t.string :referral_source
			t.boolean :affiliate_sharing_ok
			t.boolean :received_disclosure
			t.boolean :accepts_terms
			# whether our staff has approved 
			t.boolean :approved
			t.timestamps null: false
		end

  end
end
