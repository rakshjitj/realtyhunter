# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
users = User.create([
	{ fname: 'Raquel', lname: 'Bujans', email: 'rbujans@myspacenyc.com', bio: "blah blah blah", password:"713lorimer", password_confirmation:"713lorimer"},
	{ fname: 'Nir', lname: 'Mizrachi', email: 'nir@myspacenyc.com', bio: "blah blah blah", password:"713lorimer", password_confirmation:"713lorimer"},
	{ fname: 'Cheryl', lname: 'Hoyles', email: 'info@myspacenyc.com', bio: "blah blah blah", password:"713lorimer", password_confirmation:"713lorimer"},
	])