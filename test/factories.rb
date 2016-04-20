FactoryGirl.define do
  sequence :sequenced_name do |n|
    "name_#{n}"
  end

  sequence :sequenced_email do |n|
    "email_#{n}@test.com"
  end

  sequence :sequenced_number do |n|
    "#{n}"
  end

  factory :company do
    name { generate(:sequenced_name) }
  end

  def company_myspace
    # get existing group or create new one
    name = 'myspace'
    Company.where(:name => name).first || Factory(:company, :name => name)
  end

  def landlord_myspace
    # get existing group or create new one
    name = 'myspace'
    Landlord.where(:name => name).first || Factory(:landlord, :name => name)
  end

  factory :office do
    name { generate(:sequenced_name) }
    sequence(:formatted_street_address) { |n| "#{n} Franklin Ave, Brooklyn, NY 11238" }
    street_number "722"
  	route "Franklin Ave"
	  administrative_area_level_2_short "New York"
	  administrative_area_level_1_short "NY"
	  postal_code "11238"
	  country_short "US"
	  lat "123"
	  lng "123"
	  place_id "1"
	  telephone "555-555-5555"
	  company
  end

  factory :employee_title do
    name { generate(:sequenced_name) }
  end

  factory :user do
    name { generate(:sequenced_name) }
    email { generate(:sequenced_email) }
    mobile_phone_number "555-555-5555"
    password "123456"
    company
    office
  end

  factory :neighborhood do
    name { generate(:sequenced_name) }
    borough { 'Brookyln' }
    city "New York"
    state "NY"
  end

  factory :rental_term do
    name { generate(:sequenced_name) }
    company
    #company { company_myspace }
  end

  factory :landlord do
    code { generate(:sequenced_name) }
    name { generate(:sequenced_name) }
    sequence(:formatted_street_address) { |n| "#{n} Franklin Ave, Brooklyn, NY 11238" }
    street_number "722"
    route "Franklin Ave"
    administrative_area_level_2_short "New York"
    administrative_area_level_1_short "NY"
    postal_code "11238"
    country_short "US"
    lat "123"
    lng "123"
    place_id "1"
    office_phone "555-555-4444"
    mobile "555-555-3333"
    listing_agent_percentage 15
    email { generate(:sequenced_email) }
    company
    #association :rental_term, :factory => :rental_term, :username => 'admin'
  end

  factory :building_amenitiy do
    name { generate(:sequenced_name) }
  end

  factory :building do
    sequence(:formatted_street_address) { |n| "#{n} Franklin Ave, Brooklyn, NY 11238" }
    street_number "722"
    route "Franklin Ave"
    administrative_area_level_2_short "New York"
    administrative_area_level_1_short "NY"
    postal_code "11238"
    country_short "US"
    lat "123"
    lng "123"
    place_id "1"

    #landlord { landlord_myspace }
    #company { company_myspace }
    landlord
    company
    neighborhood
    pet_policy
    rental_term
    #building_amenitiy
     # user_with_posts will create post data after the user has been created
    factory :building_with_building_amenities do
      # posts_count is declared as a transient attribute and available in
      # attributes on the factory, as well as the callback via the evaluator
      transient do
        building_amenities_count 2
      end
    end
  end

  factory :pet_policy do
    name { generate(:sequenced_name) }
    company
  end

  factory :unit do
    building_unit { generate(:sequenced_number) }
    rent { generate(:sequenced_number) }
    building
  end

  factory :residential_listing do
    lease_start 12
    lease_end 12
    beds 1
    baths 2.5
    unit
  end

  factory :commercial_listing do
    # building_unit { generate(:sequenced_number) }
    # rent { generate(:sequenced_number) }
    construction_status "existing"
    lease_type "full_service"
    sq_footage { generate(:sequenced_number) }
    floor { generate(:sequenced_number) }
    building_size { generate(:sequenced_number) }
    property_description "blah"
    total_lot_size 100
    #building
    unit
  end

end
