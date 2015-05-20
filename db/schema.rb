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

ActiveRecord::Schema.define(version: 20150519180148) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agent_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "buildings", force: :cascade do |t|
    t.string   "street_address"
    t.string   "zip"
    t.string   "private_notes"
    t.integer  "company_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "commercial_units", force: :cascade do |t|
    t.string "sq_footage"
    t.string "floor"
    t.string "property_type"
    t.string "property_sub_type"
    t.string "listing_id"
    t.string "building_size"
    t.string "description"
  end

  create_table "companies", force: :cascade do |t|
    t.string   "name"
    t.string   "logo_id"
    t.string   "string"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "offices_id"
    t.integer  "users_id"
    t.integer  "buildings_id"
  end

  add_index "companies", ["buildings_id"], name: "index_companies_on_buildings_id", using: :btree
  add_index "companies", ["offices_id"], name: "index_companies_on_offices_id", using: :btree
  add_index "companies", ["users_id"], name: "index_companies_on_users_id", using: :btree

  create_table "employee_titles", force: :cascade do |t|
    t.string   "name"
    t.integer  "users_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "employee_titles", ["users_id"], name: "index_employee_titles_on_users_id", using: :btree

  create_table "neighborhoods", force: :cascade do |t|
    t.string   "name"
    t.string   "borough"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "offices", force: :cascade do |t|
    t.string   "name"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.string   "telephone"
    t.string   "fax"
    t.integer  "company_id"
    t.integer  "users_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "offices", ["users_id"], name: "index_offices_on_users_id", using: :btree

  create_table "residential_units", force: :cascade do |t|
    t.integer "beds"
    t.float   "baths"
    t.float   "notes"
    t.integer "lease_duration", default: 0
  end

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
    t.string   "building_unit"
    t.integer  "rent"
    t.datetime "available_by"
    t.string   "access_info"
    t.integer  "status",             default: 0
    t.string   "open_house"
    t.float    "weeks_free_offered"
    t.integer  "building_id"
    t.integer  "actable_id"
    t.string   "actable_type"
  end

  create_table "users", force: :cascade do |t|
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
    t.integer  "company_id"
    t.integer  "office_id"
    t.integer  "employee_title_id"
    t.integer  "manager_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "avatar_id"
    t.string   "avatar_key"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["employee_title_id"], name: "index_users_on_employee_title_id", using: :btree
  add_index "users", ["manager_id"], name: "index_users_on_manager_id", using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

end
