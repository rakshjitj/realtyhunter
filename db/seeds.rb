@company = Company.create({name: "MyspaceNYC"})
@company2 = Company.create({name: "Nooklyn"})

53.times do |n|
  Company.create({name: FFaker::Company::name})
end

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
  {name: "api_only"},
  {name: "data entry"},
  {name: "manager"},
  {name: "closing manager"},
  {name: "marketing"},
  {name: "operations"},
  {name: "company admin"},
  ])

@password = "713lorimer"

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
    employee_title: @employee_titles[@employee_titles.length-1],
    mobile_phone_number: '666-666-6666'
  })

@managers = User.create!([
  { name: 'Manager One', 
    email: 'manager1@myspacenyc.com',
    bio: "blah blah blah", 
    password: @password, 
    password_confirmation: @password, 
    activated: true, 
    activated_at: Time.zone.now,
    approved: true, 
    approved_at: Time.zone.now,
    company: @company, 
    office: @offices[0],
    employee_title: @employee_titles[6],
    mobile_phone_number: '666-666-7777'
 },
 { name: 'Manager Two', 
    email: 'manager2@myspacenyc.com',
    bio: "blah blah blah", 
    password: @password, 
    password_confirmation: @password, 
    activated: true, 
    activated_at: Time.zone.now,
    approved: true, 
    approved_at: Time.zone.now,
    company: @company, 
    office: @offices[0],
    employee_title: @employee_titles[6],
    mobile_phone_number: '666-666-7777'
 }])

@admins = User.create!([
  { name: 'Raquel Bujans', 
    email: 'rbujans@myspacenyc.com',
    bio: "blah blah blah", 
    password: @password, 
    password_confirmation: @password, 
    activated: true, 
    activated_at: Time.zone.now,
    approved: true, 
    approved_at: Time.zone.now,
    company: @company, 
    office: @offices[0],
    employee_title: @employee_titles[@employee_titles.length-1],
    mobile_phone_number: '666-666-7777'
  },
  { name: 'Cheryl Hoyles', 
    email: 'info@myspacenyc.com',
    bio: "blah blah blah", 
    password: @password, 
    password_confirmation: @password, 
    activated: true, 
    activated_at: Time.zone.now,
    approved: true, 
    approved_at: Time.zone.now,
    company: @company, 
    office: @offices[0],
    employee_title: @employee_titles[4],
    mobile_phone_number: '666-666-9999'
  },
  { name: 'Nir Mizrachi', 
    email: 'nir@myspacenyc.com',
    bio: "blah blah blah", 
    password: @password, 
    password_confirmation: @password, 
    activated: true, 
    activated_at: Time.zone.now,
    approved: true, 
    approved_at: Time.zone.now,
    company: @company, 
    office: @offices[0],
    employee_title: @employee_titles[@employee_titles.length-1],
    mobile_phone_number: '666-666-8888'
  },
  { name: 'Rose Sambrato', 
    email: 'r.sambrato@myspacenycbw.com',
    bio: "blah blah blah", 
    password: @password, 
    password_confirmation: @password, 
    activated: true, 
    activated_at: Time.zone.now,
    approved: true, 
    approved_at: Time.zone.now,
    company: @company, 
    office: @offices[0],
    employee_title: @employee_titles[@employee_titles.length-1],
    mobile_phone_number: '666-666-8888'
  },
  { name: 'Collin Mullahy', 
    email: 'cmullahy@myspacenyc.com',
    bio: "blah blah blah", 
    password: @password, 
    password_confirmation: @password, 
    activated: true, 
    activated_at: Time.zone.now,
    approved: true, 
    approved_at: Time.zone.now,
    company: @company, 
    office: @offices[0],
    employee_title: @employee_titles[@employee_titles.length-1],
    mobile_phone_number: '666-666-8888'
  },
  { name: 'Shawn Mullahy', 
    email: 'smullahy@myspacenyc.com',
    bio: "blah blah blah", 
    password: @password, 
    password_confirmation: @password, 
    activated: true, 
    activated_at: Time.zone.now,
    approved: true, 
    approved_at: Time.zone.now,
    company: @company, 
    office: @offices[0],
    employee_title: @employee_titles[@employee_titles.length-1],
    mobile_phone_number: '666-666-9999'
  },
  { name: 'Belle Taylor', 
    email: 'belle@myspacenyc.com',
    bio: "blah blah blah", 
    password: @password, 
    password_confirmation: @password, 
    activated: true, 
    activated_at: Time.zone.now,
    approved: true, 
    approved_at: Time.zone.now,
    company: @company, 
    office: @offices[0],
    employee_title: @employee_titles[@employee_titles.length-1],
    mobile_phone_number: '666-666-9999'
  },
  { name: 'Ozzie Sadok', 
    email: 'osadok@myspacenyc.com',
    bio: "blah blah blah", 
    password: @password, 
    password_confirmation: @password, 
    activated: true, 
    activated_at: Time.zone.now,
    approved: true, 
    approved_at: Time.zone.now,
    company: @company, 
    office: @offices[0],
    employee_title: @employee_titles[@employee_titles.length-1],
    mobile_phone_number: '666-666-9999'
  },
  { name: 'Benny Lewis', 
    email: 'blewis@myspacenyc.com',
    bio: "blah blah blah", 
    password: @password, 
    password_confirmation: @password, 
    activated: true, 
    activated_at: Time.zone.now,
    approved: true, 
    approved_at: Time.zone.now,
    company: @company, 
    office: @offices[0],
    employee_title: @employee_titles[@employee_titles.length-1],
    mobile_phone_number: '666-666-9999'
  },
  { name: 'Michelle Monko', 
    email: 'mmonko@myspacenyc.com',
    bio: "blah blah blah", 
    password: @password, 
    password_confirmation: @password, 
    activated: true, 
    activated_at: Time.zone.now,
    approved: true, 
    approved_at: Time.zone.now,
    company: @company, 
    office: @offices[0],
    employee_title: @employee_titles[@employee_titles.length-1],
    mobile_phone_number: '666-666-9999'
  },
  { name: 'Dani Leahy', 
    email: 'dleahy@myspacenyc.com',
    bio: "blah blah blah", 
    password: @password, 
    password_confirmation: @password, 
    activated: true, 
    activated_at: Time.zone.now,
    approved: true, 
    approved_at: Time.zone.now,
    company: @company, 
    office: @offices[0],
    employee_title: @employee_titles[@employee_titles.length-1],
    mobile_phone_number: '666-666-9999'
 }])

User.define_roles()
@super_admin.update_roles
@super_admin.add_role :super_admin

@admins.each {|a| a.update_roles }
@managers.each {|m| m.update_roles }

50.times do |n|
  name  = FFaker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = @password
  userN = User.create!(name: name,
   email: email,
   phone_number: FFaker::PhoneNumber.short_phone_number,
   mobile_phone_number: '333-333-3333',
   password:              password,
   password_confirmation: password,
   activated: true,
   activated_at: Time.zone.now,
   approved: true, 
   approved_at: Time.zone.now,
   company: @company, 
   office: @offices[0],
   employee_title: @employee_titles[1]
   )
  userN.update_roles
  if n < 25
    @managers[0].add_subordinate(userN)
  else
    @managers[1].add_subordinate(userN)
  end
end

# seed property data -----------------------------------------
@neighborhood = Neighborhood.create({
  name: "Crown Heights",
  borough: "Brooklyn",
  city: "New York",
  state: "NY"
  })

20.times do |n|
  # if name has already been taken, ignore error
  neigh = Neighborhood.create({
    name: FFaker::Address::neighborhood,
    borough: (n < 10) ? "Brooklyn" : "Queens",
    city: "New York",
    state: "NY"
  })
end

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

55.times do |n|
  ll_name = FFaker::Name.name
  
  landlordN = Landlord.create!(
    code: FFaker::HipsterIpsum.characters(10),
    name: ll_name,
    office_phone: "777-777-7777",
    mobile: "777-777-7777",
    fax: "777-777-7777",
    email: FFaker::Internet.email(ll_name),
    website: FFaker::Internet.http_url,
    notes: FFaker::HipsterIpsum.sentence,
    listing_agent_percentage: "15",
    management_info: FFaker::HipsterIpsum.phrase,
    company: @company)
end

@bldg = Building.create!({
  formatted_street_address: '1062 Bergen St, Brooklyn, NY 11216',
  street_number: '1062',
  route: 'Bergen St',
  sublocality: 'Brooklyn',
  administrative_area_level_2_short: 'New York',
  administrative_area_level_1_short: 'NY',
  postal_code: '11216',
  country_short: 'USA',
  lat: '40.6759645',
  lng: '-73.9509791',
  place_id: 1,
  notes: "Building has parking spots available, laundry in the basement.",
  company: @company, 
  landlord: @landlord,
  neighborhood: @neighborhood,
  pet_policy: @company.pet_policies[2],
  required_security: @company.required_securities[1],
  })

55.times do |n|

  ResidentialUnit.create!({
    building_unit: Faker::Number.number(2),
    rent: Faker::Number.number(4),
    beds: Faker::Number.number(1),
    baths: Faker::Number.number(1),
    available_by: Time.zone.now,
    access_info: FFaker::HipsterIpsum.phrase,
    status: "active",
    lease_duration: "year",
    weeks_free_offered: Faker::Number.number(1),
    notes: FFaker::HipsterIpsum.sentence,
    building: @bldg,
    listing_agent: @manager1,
    primary_agent: @manager1,
    op_fee_percentage: 95,
    })
end

55.times do |n|
  bldg_size = Faker::Number.number(4);
  CommercialUnit.create!({
    status: "active",
    building: @bldg,
    rent: Faker::Number.number(4),
    available_by: Time.zone.now,

    sq_footage: Faker::Number.number(3),
    floor: Faker::Number.number(1),
    build_to_suit: false,
    lease_type: "modified_gross",
    is_sublease: false,
    building_size: bldg_size,
    total_lot_size: bldg_size,
    minimum_divisble: bldg_size,
    maximum_contiguous: bldg_size,
    property_description: FFaker::HipsterIpsum.sentence,
    location_description: FFaker::HipsterIpsum.sentence,
    construction_status: "existing",
    no_parking_spaces: Faker::Number.number(1),
    pct_procurement_fee: Faker::Number.number(2),
    lease_term_months: Faker::Number.number(2),
    rate_is_negotiable: false,
    commercial_property_type: @company.commercial_property_types[0],
    })

end