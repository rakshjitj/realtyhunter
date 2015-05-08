# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

@password = "713lorimer"

users = User.create([
	{ fname: 'Raquel', 
    lname: 'Bujans',   
    email: 'rbujans@myspacenyc.com', 
    bio: "blah blah blah", 
    password: @password, 
    password_confirmation: @password, 
    activated: true, 
    activated_at: Time.zone.now },
	{ fname: 'Nir',    
    lname: 'Mizrachi', 
    email: 'nir@myspacenyc.com',     
    bio: "blah blah blah", 
    password: @password, 
    password_confirmation: @password, 
    activated: true, 
    activated_at: Time.zone.now },
	{ fname: 'Cheryl', 
    lname: 'Hoyles',   
    email: 'info@myspacenyc.com',    
    bio: "blah blah blah", 
    password: @password, 
    password_confirmation: @password, 
    activated: true, 
    activated_at: Time.zone.now},
	])
users[0].add_role :admin
users[1].add_role :admin
users[2].add_role :admin

50.times do |n|
  fname  = Faker::Name.first_name
  lname  = Faker::Name.last_name
  phone_number = Faker::PhoneNumber.phone_number
  mobile_phone_number = Faker::PhoneNumber.cell_phone
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  userN = User.create!(fname:  fname,
  						 lname: lname,
               email: email,
               phone_number: phone_number,
               mobile_phone_number: mobile_phone_number,
               password:              password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
  userN.add_role :lic_agent
end