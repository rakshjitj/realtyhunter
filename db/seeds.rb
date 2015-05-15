# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

@company = Company.create({name: "MyspaceNYC"})
@company2 = Company.create({name: "Nooklyn"})

@offices = Office.create([
  {company: @company, name: "Crown Heights", street_address: "722 Franklin Ave", city: "Brooklyn", state: "NY", zipcode: "11238", telephone: "718.399.3444", fax: "718.399.3444"},
  {company: @company, name: "Bushwick", street_address: "105 Central Ave", city: "Brooklyn", state: "NY", zipcode: "11206", telephone: "347.533.7777", fax: "347.533.7777"},
  {company: @company, name: "Williamsburg", street_address: "713 Lorimer St", city: "Brooklyn", state: "NY", zipcode: "11211", telephone: "718.564.6300", fax: "718.564.6300"},
  {company: @company, name: "Lefferts Gardens", street_address: "661 Flatbush Ave", city: "Brooklyn", state: "NY", zipcode: "11225", telephone: "718.408.8881", fax: "718.408.8881"},
  {company: @company, name: "Williamsburg - Leasing", street_address: "297 Broadway, 2nd Fl", city: "Brooklyn", state: "NY", zipcode: "11211", telephone: "555-555-5555", fax: "555-555-5555"},
  ])

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
  name  = Faker::Name.name
  phone_number = Faker::PhoneNumber.phone_number
  mobile_phone_number = Faker::PhoneNumber.cell_phone
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  userN = User.create!(name: name,
               email: email,
               phone_number: phone_number,
               mobile_phone_number: mobile_phone_number,
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

