@company = Company.create_with_environment({name: "MyspaceNYC"})
@company2 = Company.create_with_environment({name: "Nooklyn"})

@offices = Office.create([
  {company: @company, name: "Crown Heights", street_address: "722 Franklin Ave", city: "Brooklyn", state: "NY", zipcode: "11238", telephone: "718.399.3444", fax: "718.399.3444"},
  {company: @company, name: "Bushwick", street_address: "105 Central Ave", city: "Brooklyn", state: "NY", zipcode: "11206", telephone: "347.533.7777", fax: "347.533.7777"},
  {company: @company, name: "Williamsburg", street_address: "713 Lorimer St", city: "Brooklyn", state: "NY", zipcode: "11211", telephone: "718.564.6300", fax: "718.564.6300"},
  {company: @company, name: "Lefferts Gardens", street_address: "661 Flatbush Ave", city: "Brooklyn", state: "NY", zipcode: "11225", telephone: "718.408.8881", fax: "718.408.8881"},
  {company: @company, name: "Williamsburg - Leasing", street_address: "297 Broadway, 2nd Fl", city: "Brooklyn", state: "NY", zipcode: "11211", telephone: "555-555-5555", fax: "555-555-5555"},
  ])


# seed user data -----------------------------------------

@agent_types = AgentType.create([
  {name: "residential"},
  {name: "commercial"},
  {name: "sales"},
  {name: "roomsharing"},
  ])

@employee_titles = EmployeeTitle.create([
  {name: "unlicensed agent"},
  {name: "agent"},
  {name: "associate broker"},
  {name: "broker"},
  {name: "manager"},
  {name: "closing manager"},
  {name: "marketing"},
  {name: "operations"},
  {name: "company admin"},
  ])

@password = "713lorimer"

# super admin
@super_admin = User.create(
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
  })
@company_admin1 = User.create({ name: 'Raquel Bujans', 
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
 })
@manager1 = User.create({ name: 'Nir Mizrachi', 
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
    employee_title: @employee_titles[4],
  })
@manager2 = User.create({ name: 'Cheryl Hoyles', 
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
 })

User.define_roles()
@super_admin.update_roles
@super_admin.add_role :super_admin

@company_admin1.update_roles
@manager1.update_roles
@manager2.update_roles

50.times do |n|
  name  = FFaker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  userN = User.create!(name: name,
   email: email,
   phone_number: FFaker::PhoneNumber.short_phone_number,
   mobile_phone_number: FFaker::PhoneNumber.short_phone_number,
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
  #if n < 20
  #  @company_admin1.add_subordinate(userN)
  #elsif 20 < n && n < 35
  if n < 25
    @manager1.add_subordinate(userN)
  else
    @manager2.add_subordinate(userN)
  end
end

# seed property data -----------------------------------------
@neighborhood = Neighborhood.create({
  name: "Crown Heights",
  borough: "Brooklyn",
  city: "New York",
  state: "NY"
  })

@landlord = Landlord.create({
  code: "Unassigned", 
  name: "Unassigned", 
  phone: "777-777-7777",
  mobile: "777-777-7777",
  email: FFaker::Internet.email("Unassigned"),
  notes: "Catch-all landlord used to find unassigned buildings",
  listing_agent_percentage: "15",
  months_required: "first_month",
  company: @company
  })

55.times do |n|
  ll_name = FFaker::Name.name
  
  landlordN = Landlord.create!(
    code: FFaker::HipsterIpsum.characters(10),
    name: ll_name,
    phone: "777-777-7777",
    mobile: "777-777-7777",
    fax: "777-777-7777",
    email: FFaker::Internet.email(ll_name),
    website: FFaker::Internet.http_url,
    street_address: FFaker::AddressUS.street_address,
    city: FFaker::AddressUS.city,
    state: FFaker::AddressUS.state_abbr,
    zipcode: FFaker::AddressUS.zip_code,
    notes: FFaker::HipsterIpsum.sentence,
    listing_agent_percentage: "15",
    months_required: "first_month",
    management_info: FFaker::HipsterIpsum.phrase,
    company: @company)
end

@bldg = Building.create({
  formatted_street_address: '1062 Bergen St, Brooklyn, NY 11216',
  street_number: '1062',
  route: 'Bergen St',
  sublocality: 'Brooklyn',
  administrative_area_level_2_short: 'New York',
  administrative_area_level_1_short: 'NY',
  postal_code: '11216',
  country_short: 'USA',
  lat: '10',
  lng: '11',
  place_id: 1,
  notes: "Building has parking spots available, laundry in the basement.",
  company: @company, 
  landlord: @landlord,
  neighborhood: @neighborhood,
  listing_agent: @manager1
  })

55.times do |n|
  ResidentialUnit.create({
    building_unit: Faker::Number.number(1),
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
    })
end