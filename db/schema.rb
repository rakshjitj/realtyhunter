# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150726203142) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agent_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "building_amenities", force: :cascade do |t|
    t.string   "name"
    t.integer  "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "building_amenities_buildings", id: false, force: :cascade do |t|
    t.integer "building_id"
    t.integer "building_amenity_id"
  end

  create_table "buildings", force: :cascade do |t|
    t.boolean  "archived",                          default: false
    t.string   "formatted_street_address"
    t.string   "street_number"
    t.string   "route"
    t.string   "intersection"
    t.string   "sublocality"
    t.string   "administrative_area_level_2_short"
    t.string   "administrative_area_level_1_short"
    t.string   "postal_code"
    t.string   "country_short"
    t.string   "lat"
    t.string   "lng"
    t.string   "place_id"
    t.string   "notes"
    t.integer  "company_id"
    t.integer  "landlord_id"
    t.integer  "neighborhood_id"
    t.integer  "pet_policy_id"
    t.integer  "rental_term_id"
    t.integer  "images_id"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "listing_agent_id"
    t.integer  "listing_agent_percentage"
    t.boolean  "has_fee"
    t.integer  "op_fee_percentage"
    t.integer  "tp_fee_percentage"
  end

  add_index "buildings", ["formatted_street_address"], name: "index_buildings_on_formatted_street_address", using: :btree
  add_index "buildings", ["images_id"], name: "index_buildings_on_images_id", using: :btree
  add_index "buildings", ["listing_agent_id"], name: "index_buildings_on_listing_agent_id", using: :btree
  add_index "buildings", ["updated_at"], name: "index_buildings_on_updated_at", using: :btree

  create_table "buildings_utilities", id: false, force: :cascade do |t|
    t.integer "building_id"
    t.integer "utility_id"
  end

  create_table "commercial_listings", force: :cascade do |t|
    t.integer  "sq_footage"
    t.integer  "floor"
    t.integer  "building_size"
    t.boolean  "build_to_suit",               default: false
    t.integer  "minimum_divisible"
    t.integer  "maximum_contiguous"
    t.integer  "lease_type"
    t.boolean  "is_sublease",                 default: false
    t.string   "property_description"
    t.string   "location_description"
    t.integer  "construction_status",         default: 0
    t.integer  "no_parking_spaces"
    t.integer  "pct_procurement_fee"
    t.integer  "lease_term_months"
    t.boolean  "rate_is_negotiable"
    t.integer  "total_lot_size"
    t.integer  "commercial_property_type_id"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "unit_id"
  end

  create_table "commercial_property_types", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "property_type"
    t.string   "property_sub_type"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "commercial_units", force: :cascade do |t|
    t.integer "sq_footage"
    t.integer "floor"
    t.integer "building_size"
    t.boolean "build_to_suit",               default: false
    t.integer "minimum_divisble"
    t.integer "maximum_contiguous"
    t.integer "lease_type"
    t.boolean "is_sublease",                 default: false
    t.string  "property_description"
    t.string  "location_description"
    t.integer "construction_status",         default: 0
    t.integer "no_parking_spaces"
    t.integer "pct_procurement_fee"
    t.integer "lease_term_months"
    t.boolean "rate_is_negotiable"
    t.integer "total_lot_size"
    t.integer "commercial_property_type_id"
  end

  create_table "companies", force: :cascade do |t|
    t.boolean  "archived",                 default: false
    t.string   "name"
    t.string   "logo_id"
    t.string   "string"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "offices_id"
    t.integer  "users_id"
    t.integer  "buildings_id"
    t.integer  "landlords_id"
    t.integer  "building_amenities_id"
    t.integer  "utilities_id"
    t.integer  "rental_terms_id"
    t.integer  "pet_policies_id"
    t.integer  "residential_amenities_id"
  end

  add_index "companies", ["building_amenities_id"], name: "index_companies_on_building_amenities_id", using: :btree
  add_index "companies", ["buildings_id"], name: "index_companies_on_buildings_id", using: :btree
  add_index "companies", ["landlords_id"], name: "index_companies_on_landlords_id", using: :btree
  add_index "companies", ["name"], name: "index_companies_on_name", using: :btree
  add_index "companies", ["offices_id"], name: "index_companies_on_offices_id", using: :btree
  add_index "companies", ["pet_policies_id"], name: "index_companies_on_pet_policies_id", using: :btree
  add_index "companies", ["rental_terms_id"], name: "index_companies_on_rental_terms_id", using: :btree
  add_index "companies", ["residential_amenities_id"], name: "index_companies_on_residential_amenities_id", using: :btree
  add_index "companies", ["users_id"], name: "index_companies_on_users_id", using: :btree
  add_index "companies", ["utilities_id"], name: "index_companies_on_utilities_id", using: :btree

  create_table "employee_titles", force: :cascade do |t|
    t.string   "name"
    t.integer  "users_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "employee_titles", ["users_id"], name: "index_employee_titles_on_users_id", using: :btree

  create_table "images", force: :cascade do |t|
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.boolean  "file_processing"
    t.integer  "priority"
    t.integer  "building_id"
    t.integer  "unit_id"
    t.integer  "user_id"
    t.integer  "company_id"
  end

  add_index "images", ["user_id"], name: "index_images_on_user_id", using: :btree

  create_table "landlords", force: :cascade do |t|
    t.boolean  "archived",                          default: false
    t.string   "formatted_street_address"
    t.string   "street_number"
    t.string   "route"
    t.string   "sublocality"
    t.string   "administrative_area_level_2_short"
    t.string   "administrative_area_level_1_short"
    t.string   "postal_code"
    t.string   "neighborhood"
    t.string   "country_short"
    t.string   "lat"
    t.string   "lng"
    t.string   "place_id"
    t.string   "code"
    t.string   "name"
    t.string   "contact_name"
    t.string   "office_phone"
    t.string   "mobile"
    t.string   "fax"
    t.string   "email"
    t.string   "website"
    t.text     "notes"
    t.integer  "listing_agent_percentage"
    t.string   "management_info"
    t.string   "key_pick_up_location"
    t.integer  "company_id"
    t.integer  "buildings_id"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "update_source"
  end

  add_index "landlords", ["buildings_id"], name: "index_landlords_on_buildings_id", using: :btree
  add_index "landlords", ["code"], name: "index_landlords_on_code", using: :btree

  create_table "neighborhoods", force: :cascade do |t|
    t.boolean  "archived",     default: false
    t.string   "name"
    t.string   "borough"
    t.string   "city"
    t.string   "state"
    t.integer  "buildings_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "neighborhoods", ["buildings_id"], name: "index_neighborhoods_on_buildings_id", using: :btree

  create_table "offices", force: :cascade do |t|
    t.boolean  "archived",                          default: false
    t.string   "formatted_street_address"
    t.string   "street_number"
    t.string   "route"
    t.string   "sublocality"
    t.string   "administrative_area_level_2_short"
    t.string   "administrative_area_level_1_short"
    t.string   "postal_code"
    t.string   "neighborhood"
    t.string   "country_short"
    t.string   "lat"
    t.string   "lng"
    t.string   "place_id"
    t.string   "name"
    t.string   "telephone"
    t.string   "fax"
    t.integer  "company_id"
    t.integer  "users_id"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  add_index "offices", ["users_id"], name: "index_offices_on_users_id", using: :btree

  create_table "pet_policies", force: :cascade do |t|
    t.string   "name"
    t.integer  "company_id"
    t.integer  "building_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "pet_policies", ["building_id"], name: "index_pet_policies_on_building_id", using: :btree

  create_table "rental_terms", force: :cascade do |t|
    t.string   "name"
    t.integer  "company_id"
    t.integer  "building_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "rental_terms", ["building_id"], name: "index_rental_terms_on_building_id", using: :btree

  create_table "residential_amenities", force: :cascade do |t|
    t.string   "name"
    t.integer  "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "residential_amenities_listings", id: false, force: :cascade do |t|
    t.integer "residential_listing_id"
    t.integer "residential_amenity_id"
  end

  create_table "residential_amenities_units", id: false, force: :cascade do |t|
    t.integer "residential_unit_id"
    t.integer "residential_amenity_id"
    t.integer "residential_listing_id"
  end

  create_table "residential_listings", force: :cascade do |t|
    t.integer  "beds"
    t.float    "baths"
    t.string   "notes"
    t.string   "description"
    t.string   "lease_start"
    t.string   "lease_end"
    t.boolean  "has_fee"
    t.integer  "op_fee_percentage"
    t.integer  "tp_fee_percentage"
    t.boolean  "tenant_occupied",   default: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "unit_id"
  end

  create_table "residential_units", force: :cascade do |t|
    t.integer "beds"
    t.float   "baths"
    t.string  "notes"
    t.string  "lease_start"
    t.string  "lease_end"
    t.boolean "has_fee"
    t.integer "op_fee_percentage"
    t.integer "tp_fee_percentage"
    t.boolean "tenant_occupied",   default: false
    t.string  "description"
  end

  add_index "residential_units", ["baths"], name: "index_residential_units_on_baths", using: :btree
  add_index "residential_units", ["beds"], name: "index_residential_units_on_beds", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "units", force: :cascade do |t|
    t.boolean  "archived",               default: false
    t.integer  "listing_id"
    t.string   "building_unit"
    t.integer  "rent"
    t.datetime "available_by"
    t.string   "access_info"
    t.integer  "status",                 default: 0
    t.string   "open_house"
    t.boolean  "oh_exclusive",           default: false
    t.integer  "building_id"
    t.integer  "listing_agent_id"
    t.integer  "primary_agent_id"
    t.integer  "images_id"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "actable_id"
    t.string   "actable_type"
    t.integer  "residential_listing_id"
    t.integer  "commercial_listing_id"
  end

  add_index "units", ["commercial_listing_id"], name: "index_units_on_commercial_listing_id", using: :btree
  add_index "units", ["images_id"], name: "index_units_on_images_id", using: :btree
  add_index "units", ["rent"], name: "index_units_on_rent", using: :btree
  add_index "units", ["residential_listing_id"], name: "index_units_on_residential_listing_id", using: :btree
  add_index "units", ["status"], name: "index_units_on_status", using: :btree
  add_index "units", ["updated_at"], name: "index_units_on_updated_at", using: :btree

  create_table "users", force: :cascade do |t|
    t.boolean  "archived",            default: false
    t.string   "auth_token"
    t.string   "name"
    t.string   "email"
    t.string   "phone_number"
    t.string   "mobile_phone_number"
    t.string   "password_digest"
    t.string   "remember_digest"
    t.text     "bio"
    t.string   "activation_digest"
    t.boolean  "activated",           default: false
    t.datetime "activated_at"
    t.string   "approval_digest"
    t.boolean  "approved",            default: false
    t.datetime "approved_at"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.datetime "last_login_at"
    t.integer  "company_id"
    t.integer  "office_id"
    t.integer  "employee_title_id"
    t.integer  "manager_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["employee_title_id"], name: "index_users_on_employee_title_id", using: :btree
  add_index "users", ["manager_id"], name: "index_users_on_manager_id", using: :btree
  add_index "users", ["name"], name: "index_users_on_name", using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  create_table "utilities", force: :cascade do |t|
    t.string   "name"
    t.integer  "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
