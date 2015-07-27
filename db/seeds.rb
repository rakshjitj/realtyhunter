# this is just so we can define the busines logic in a centralized place.
# this is a non-functional user
def define_roles
  @user = User.create({
    email: 'topsecret@admin.com', 
    name: "Roles Definition",
    password:"test123" });
  # Inactive Agent:
  @user.add_role :inactive_agent
  # Licensed Agent:
  @user.add_role :residential
  @user.add_role :commercial
  @user.add_role :sales
  @user.add_role :roomsharing
  @user.add_role :associate_broker
  @user.add_role :broker
  # Executive Agent:
  @user.add_role :external_vendor
  @user.add_role :data_entry
  @user.add_role :manager
  @user.add_role :closing_manager
  @user.add_role :marketing
  @user.add_role :operations
  @user.add_role :company_admin
  # Not for nestio:
  @user.add_role :super_admin

  @user.delete
end


### Ok, let's get started! ######

@company = Company.create({name: "MyspaceNYC"})
@company2 = Company.create({name: "Nooklyn"})

# 53.times do |n|
#   Company.create({name: FFaker::Company::name})
# end

@offices = Office.create!([
  { company: @company, 
    name: "Crown Heights", 
    telephone: "718.399.3444",
    fax: "718.399.3444",

    formatted_street_address: '722 Franklin Ave, Brooklyn, NY 11238',
    street_number: '722',
    route: 'Franklin Ave',
    sublocality: 'Brooklyn',
    administrative_area_level_2_short: 'New York',
    administrative_area_level_1_short: 'NY',
    postal_code: '11238',
    country_short: 'USA',
    lat: '40.6759645',
    lng: '-73.9509791',
    place_id: 1,
    },
  { company: @company, 
    name: "Bushwick", 
    telephone: "718.399.3444",
    fax: "718.399.3444",

    formatted_street_address: '105 Central Ave, Brooklyn, NY 11238',
    street_number: '105',
    route: 'Central Ave',
    sublocality: 'Brooklyn',
    administrative_area_level_2_short: 'New York',
    administrative_area_level_1_short: 'NY',
    postal_code: '11205',
    country_short: 'USA',
    lat: '40.6759645',
    lng: '-73.9509791',
    place_id: 1,
    },
  { company: @company, 
    name: "Williamsburg", 
    telephone: "718.564.6300",
    fax: "718.564.6300",

    formatted_street_address: '713 Lorimer St, Brooklyn, NY 11238',
    street_number: '713',
    route: 'Lorimer St',
    sublocality: 'Brooklyn',
    administrative_area_level_2_short: 'New York',
    administrative_area_level_1_short: 'NY',
    postal_code: '11205',
    country_short: 'USA',
    lat: '40.6759645',
    lng: '-73.9509791',
    place_id: 1,
    },
  { company: @company, 
    name: "Lefferts Gardens", 
    telephone: "718.408.8881",
    fax: "718.408.8881",

    formatted_street_address: '661 Flatbush Ave, Brooklyn, NY 11238',
    street_number: '661',
    route: 'Flatbush Ave',
    sublocality: 'Brooklyn',
    administrative_area_level_2_short: 'New York',
    administrative_area_level_1_short: 'NY',
    postal_code: '11205',
    country_short: 'USA',
    lat: '40.6759645',
    lng: '-73.9509791',
    place_id: 1,
    },
  { company: @company, 
    name: "Williamsburg - Leasing", 
    telephone: "718.408.88810",
    fax: "555.555.5555",

    formatted_street_address: '297 Broadway, 2nd Fl, Brooklyn, NY 11238',
    street_number: '297',
    route: 'Broadway',
    sublocality: 'Brooklyn',
    administrative_area_level_2_short: 'New York',
    administrative_area_level_1_short: 'NY',
    postal_code: '11205',
    country_short: 'USA',
    lat: '40.6759645',
    lng: '-73.9509791',
    place_id: 1,
    },
  ])

# seed user data -----------------------------------------

@agent_types = AgentType.create!([
  {name: "residential"},
  {name: "commercial"},
  {name: "sales"},
  {name: "roomsharing"},
  ])

@employee_titles = EmployeeTitle.create!([
  {name: "unlicensed agent"},
  {name: "agent"},
  {name: "associate broker"},
  {name: "broker"},
  {name: "external vendor"},
  {name: "data entry"},
  {name: "manager"},
  {name: "closing manager"},
  {name: "marketing"},
  {name: "operations"},
  {name: "company admin"},
  {name: "super admin"},
  ])

@password = "Myspace123"

# give them agent access
@api_only = User.create!(
  { name: 'Blank Slate', 
    email: 'admin@blankslate.com', 
    password: 'blankslate', 
    password_confirmation: 'blankslate', 
    activated: true, 
    activated_at: Time.zone.now,
    approved: true, 
    approved_at: Time.zone.now,
    company: @company, 
    office: @offices[0],
    employee_title: EmployeeTitle.find_by(name: 'agent'),
    mobile_phone_number: '666-666-6666'
  })
@api_only.agent_types = ['residential', 'commercial']

# super admin
@super_admin = User.create!(
  { name: 'Super Admin', 
    email: 'admin@realtymonster.com', 
    password: @password, 
    password_confirmation: @password, 
    activated: true, 
    activated_at: Time.zone.now,
    approved: true, 
    approved_at: Time.zone.now,
    company: @company, 
    office: @offices[0],
    employee_title: EmployeeTitle.find_by(name: 'super admin'),
    mobile_phone_number: '666-666-6666'
  })
@super_admin.agent_types = ['residential', 'commercial']

@company_admin1 = User.create!(
  { name: 'Nir Mizrachi', 
    email: 'nir@myspacenyc.com', 
    password: @password, 
    password_confirmation: @password, 
    activated: true, 
    activated_at: Time.zone.now,
    approved: true, 
    approved_at: Time.zone.now,
    company: @company, 
    office: @offices[0],
    employee_title: EmployeeTitle.find_by(name: 'company admin'),
    mobile_phone_number: '929-258-7847'
  })
@company_admin1.agent_types = ['residential', 'commercial']

define_roles
@company_admin1.update_roles
@api_only.update_roles
@super_admin.update_roles
@super_admin.add_role :super_admin

# 50.times do |n|
#   name  = FFaker::Name.name
#   email = "example-#{n+1}@railstutorial.org"
#   password = @password
#   userN = User.create!(name: name,
#    email: email,
#    phone_number: FFaker::PhoneNumber.short_phone_number,
#    mobile_phone_number: '333-333-3333',
#    password:              password,
#    password_confirmation: password,
#    activated: true,
#    activated_at: Time.zone.now,
#    approved: true, 
#    approved_at: Time.zone.now,
#    company: @company, 
#    office: @offices[0],
#    employee_title: @employee_titles[1]
#    )
#   userN.update_roles
# end

# seed property data -----------------------------------------
@neighborhood = Neighborhood.create({
  name: "Crown Heights",
  borough: "Brooklyn",
  city: "New York",
  state: "NY"
  })

@landlord = Landlord.create!({
  code: "Unassigned", 
  name: "Unassigned", 
  office_phone: "777-777-7777",
  mobile: "777-777-7777",
  email: FFaker::Internet.email("Unassigned"),
  notes: "Catch-all landlord used to find unassigned buildings",
  listing_agent_percentage: "15",
  company: @company,
  })

@bldg = Building.create!({
  formatted_street_address: '722 Franklin Ave, Brooklyn, NY 11238',
  street_number: '722',
  route: 'Franklin Ave',
  sublocality: 'Brooklyn',
  administrative_area_level_2_short: 'New York',
  administrative_area_level_1_short: 'NY',
  postal_code: '11238',
  country_short: 'USA',
  lat: '40.6759645',
  lng: '-73.9509791',
  place_id: 1,
  notes: "Building has parking spots available, laundry in the basement.",
  company: @company, 
  landlord: @landlord,
  neighborhood: @neighborhood,
  pet_policy: @company.pet_policies[2],
  rental_term: @company.rental_terms[1],
  })

# 55.times do |n|

#   ResidentialListing.create!({
#     building_unit: Faker::Number.number(2),
#     rent: Faker::Number.number(4),
#     beds: Faker::Number.number(1),
#     baths: Faker::Number.number(1),
#     available_by: Time.zone.now,
#     access_info: FFaker::HipsterIpsum.phrase,
#     status: "active",
#     lease_duration: "year",
#     notes: FFaker::HipsterIpsum.sentence,
#     building: @bldg,
#     listing_agent: @manager1,
#     primary_agent: @manager1,
#     op_fee_percentage: 95,
#     })
# end

# 55.times do |n|
#   bldg_size = Faker::Number.number(4);
#   CommercialUnit.create!({
#     status: "active",
#     building: @bldg,
#     rent: Faker::Number.number(4),
#     available_by: Time.zone.now,

#     sq_footage: Faker::Number.number(3),
#     floor: Faker::Number.number(1),
#     build_to_suit: false,
#     lease_type: "modified_gross",
#     is_sublease: false,
#     building_size: bldg_size,
#     total_lot_size: bldg_size,
#     minimum_divisble: bldg_size,
#     maximum_contiguous: bldg_size,
#     property_description: FFaker::HipsterIpsum.sentence,
#     location_description: FFaker::HipsterIpsum.sentence,
#     construction_status: "existing",
#     no_parking_spaces: Faker::Number.number(1),
#     pct_procurement_fee: Faker::Number.number(2),
#     lease_term_months: Faker::Number.number(2),
#     rate_is_negotiable: false,
#     commercial_property_type: @company.commercial_property_types[0],
#     })
# end