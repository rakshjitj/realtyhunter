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

ActiveRecord::Schema.define(version: 20170802093713) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"

  create_table "announcements", force: :cascade do |t|
    t.string   "note"
    t.boolean  "was_broadcast", default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "user_id"
    t.integer  "category"
  end

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         default: 0
    t.string   "comment"
    t.string   "remote_address"
    t.string   "request_uuid"
    t.datetime "created_at"
    t.index ["associated_id", "associated_type"], name: "associated_index", using: :btree
    t.index ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
    t.index ["created_at"], name: "index_audits_on_created_at", using: :btree
    t.index ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
    t.index ["user_id", "user_type"], name: "user_index", using: :btree
  end

  create_table "bootsy_image_galleries", force: :cascade do |t|
    t.integer  "bootsy_resource_id"
    t.string   "bootsy_resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bootsy_images", force: :cascade do |t|
    t.string   "image_file"
    t.integer  "image_gallery_id"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.integer  "documents_id"
    t.integer  "lock_version",                      default: 0,     null: false
    t.integer  "total_unit_count",                  default: 0,     null: false
    t.integer  "active_unit_count",                 default: 0,     null: false
    t.datetime "last_unit_updated_at"
    t.string   "llc_name"
    t.integer  "feedback_id"
    t.string   "knack_id"
    t.index ["documents_id"], name: "index_buildings_on_documents_id", using: :btree
    t.index ["feedback_id"], name: "index_buildings_on_feedback_id", using: :btree
    t.index ["formatted_street_address"], name: "index_buildings_on_formatted_street_address", using: :btree
    t.index ["images_id"], name: "index_buildings_on_images_id", using: :btree
    t.index ["updated_at"], name: "index_buildings_on_updated_at", order: { updated_at: :desc }, using: :btree
  end

  create_table "buildings_utilities", id: false, force: :cascade do |t|
    t.integer "building_id"
    t.integer "utility_id"
  end

  create_table "checkins", force: :cascade do |t|
    t.integer  "unit_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clients", force: :cascade do |t|
    t.string   "name"
    t.datetime "date_of_birth"
    t.string   "phone"
    t.string   "email"
    t.boolean  "archived",      default: false
    t.integer  "deal_id"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.integer  "lease_term_months"
    t.boolean  "rate_is_negotiable"
    t.integer  "total_lot_size"
    t.integer  "commercial_property_type_id"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "unit_id"
    t.boolean  "liquor_eligible"
    t.boolean  "has_basement"
    t.string   "basement_sq_footage"
    t.boolean  "has_ventilation"
    t.boolean  "key_money_required"
    t.integer  "key_money_amt"
    t.string   "listing_title"
    t.integer  "lock_version",                default: 0,     null: false
    t.boolean  "favorites",                   default: true
    t.boolean  "show",                        default: true
    t.boolean  "expose_address",              default: false
    t.index ["unit_id"], name: "index_commercial_listings_on_unit_id", using: :btree
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
    t.boolean  "archived",                  default: false
    t.string   "name"
    t.string   "logo_id"
    t.string   "string"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "offices_id"
    t.integer  "users_id"
    t.integer  "buildings_id"
    t.integer  "landlords_id"
    t.integer  "building_amenities_id"
    t.integer  "utilities_id"
    t.integer  "rental_terms_id"
    t.integer  "pet_policies_id"
    t.integer  "residential_amenities_id"
    t.integer  "sales_amenities_id"
    t.string   "website"
    t.text     "privacy_policy"
    t.text     "terms_conditions"
    t.integer  "roommates_id"
    t.integer  "wufoo_contact_us_forms_id"
    t.integer  "wufoo_partner_forms_id"
    t.integer  "wufoo_listings_forms_id"
    t.integer  "wufoo_career_forms_id"
    t.integer  "lock_version",              default: 0,     null: false
    t.index ["building_amenities_id"], name: "index_companies_on_building_amenities_id", using: :btree
    t.index ["buildings_id"], name: "index_companies_on_buildings_id", using: :btree
    t.index ["landlords_id"], name: "index_companies_on_landlords_id", using: :btree
    t.index ["name"], name: "index_companies_on_name", using: :btree
    t.index ["offices_id"], name: "index_companies_on_offices_id", using: :btree
    t.index ["pet_policies_id"], name: "index_companies_on_pet_policies_id", using: :btree
    t.index ["rental_terms_id"], name: "index_companies_on_rental_terms_id", using: :btree
    t.index ["residential_amenities_id"], name: "index_companies_on_residential_amenities_id", using: :btree
    t.index ["roommates_id"], name: "index_companies_on_roommates_id", using: :btree
    t.index ["sales_amenities_id"], name: "index_companies_on_sales_amenities_id", using: :btree
    t.index ["users_id"], name: "index_companies_on_users_id", using: :btree
    t.index ["utilities_id"], name: "index_companies_on_utilities_id", using: :btree
    t.index ["wufoo_career_forms_id"], name: "index_companies_on_wufoo_career_forms_id", using: :btree
    t.index ["wufoo_contact_us_forms_id"], name: "index_companies_on_wufoo_contact_us_forms_id", using: :btree
    t.index ["wufoo_listings_forms_id"], name: "index_companies_on_wufoo_listings_forms_id", using: :btree
    t.index ["wufoo_partner_forms_id"], name: "index_companies_on_wufoo_partner_forms_id", using: :btree
  end

  create_table "deals", force: :cascade do |t|
    t.string   "price"
    t.string   "client"
    t.string   "lease_term"
    t.datetime "lease_start_date"
    t.datetime "lease_expiration_date"
    t.datetime "closed_date"
    t.datetime "move_in_date"
    t.string   "commission"
    t.string   "deal_notes"
    t.string   "listing_type"
    t.string   "landlord_code"
    t.boolean  "is_sale_deal"
    t.boolean  "archived",              default: false
    t.integer  "unit_id"
    t.integer  "user_id"
    t.integer  "clients_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",          default: 0,     null: false
    t.string   "full_address"
    t.string   "building_unit"
    t.integer  "state",                 default: 0,     null: false
    t.integer  "rented_by_agent_id"
    t.index ["rented_by_agent_id"], name: "index_deals_on_rented_by_agent_id", using: :btree
  end

  create_table "documents", force: :cascade do |t|
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.boolean  "file_processing"
    t.integer  "priority"
    t.integer  "building_id"
    t.integer  "unit_id"
  end

  create_table "employee_titles", force: :cascade do |t|
    t.string   "name"
    t.integer  "users_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["users_id"], name: "index_employee_titles_on_users_id", using: :btree
  end

  create_table "feedbacks", force: :cascade do |t|
    t.integer  "unit_id"
    t.integer  "building_id"
    t.integer  "user_id"
    t.text     "description"
    t.boolean  "price_drop_request", default: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.index ["building_id"], name: "index_feedbacks_on_building_id", using: :btree
    t.index ["unit_id"], name: "index_feedbacks_on_unit_id", using: :btree
    t.index ["user_id"], name: "index_feedbacks_on_user_id", using: :btree
  end

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
    t.integer  "rotation",          default: 0, null: false
    t.index ["building_id"], name: "index_images_on_building_id", using: :btree
    t.index ["unit_id"], name: "index_images_on_unit_id", using: :btree
    t.index ["user_id"], name: "index_images_on_user_id", using: :btree
  end

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
    t.string   "management_info"
    t.string   "key_pick_up_location"
    t.integer  "company_id"
    t.integer  "buildings_id"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "update_source"
    t.integer  "listing_agent_id"
    t.integer  "listing_agent_percentage"
    t.integer  "op_fee_percentage"
    t.boolean  "has_fee"
    t.integer  "tp_fee_percentage"
    t.integer  "lock_version",                      default: 0,     null: false
    t.integer  "total_unit_count",                  default: 0,     null: false
    t.integer  "active_unit_count",                 default: 0,     null: false
    t.datetime "last_unit_updated_at"
    t.string   "knack_id"
    t.index ["buildings_id"], name: "index_landlords_on_buildings_id", using: :btree
    t.index ["code"], name: "index_landlords_on_code", using: :btree
    t.index ["listing_agent_id"], name: "index_landlords_on_listing_agent_id", using: :btree
    t.index ["updated_at"], name: "index_landlords_on_updated_at", order: { updated_at: :desc }, using: :btree
  end

  create_table "neighborhoods", force: :cascade do |t|
    t.boolean  "archived",     default: false
    t.string   "name"
    t.string   "borough"
    t.string   "city"
    t.string   "state"
    t.integer  "buildings_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "roommates_id"
    t.index ["buildings_id"], name: "index_neighborhoods_on_buildings_id", using: :btree
    t.index ["roommates_id"], name: "index_neighborhoods_on_roommates_id", using: :btree
  end

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
    t.index ["users_id"], name: "index_offices_on_users_id", using: :btree
  end

  create_table "open_houses", force: :cascade do |t|
    t.time     "start_time"
    t.time     "end_time"
    t.date     "day"
    t.integer  "unit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["unit_id"], name: "index_open_houses_on_unit_id", using: :btree
  end

  create_table "pet_policies", force: :cascade do |t|
    t.string   "name"
    t.integer  "company_id"
    t.integer  "building_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["building_id"], name: "index_pet_policies_on_building_id", using: :btree
  end

  create_table "rental_terms", force: :cascade do |t|
    t.string   "name"
    t.integer  "company_id"
    t.integer  "building_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["building_id"], name: "index_rental_terms_on_building_id", using: :btree
  end

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
    t.boolean  "tenant_occupied",     default: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "unit_id"
    t.integer  "lock_version",        default: 0,     null: false
    t.integer  "roommates_id"
    t.boolean  "favorites",           default: false
    t.boolean  "show",                default: true
    t.boolean  "expose_address",      default: false
    t.integer  "floor"
    t.integer  "total_room_count"
    t.string   "condition"
    t.string   "showing_instruction"
    t.decimal  "commission_amount"
    t.boolean  "cyof",                default: false
    t.date     "rented_date"
    t.boolean  "rlsny",               default: false
    t.boolean  "share_with_brokers",  default: false
    t.boolean  "rls_flag",            default: false
    t.boolean  "streeteasy_flag",     default: false
    t.string   "knack_id"
    t.index ["roommates_id"], name: "index_residential_listings_on_roommates_id", using: :btree
    t.index ["unit_id"], name: "index_residential_listings_on_unit_id", using: :btree
    t.index ["updated_at"], name: "index_residential_listings_on_updated_at", order: { updated_at: :desc }, using: :btree
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
    t.index ["baths"], name: "index_residential_units_on_baths", using: :btree
    t.index ["beds"], name: "index_residential_units_on_beds", using: :btree
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
    t.index ["name"], name: "index_roles_on_name", using: :btree
  end

  create_table "roommates", force: :cascade do |t|
    t.string   "name"
    t.string   "phone_number"
    t.string   "email"
    t.string   "how_did_you_hear_about_us"
    t.string   "upload_picture_of_yourself"
    t.string   "describe_yourself"
    t.string   "monthly_budget"
    t.datetime "move_in_date"
    t.integer  "neighborhood_id"
    t.boolean  "dogs_allowed"
    t.boolean  "cats_allowed"
    t.string   "created_by"
    t.boolean  "archived",                   default: false
    t.integer  "company_id"
    t.integer  "user_id"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "lock_version",               default: 0,     null: false
    t.string   "internal_notes"
    t.boolean  "read",                       default: false
    t.integer  "residential_listing_id"
    t.string   "do_you_have_pets"
  end

  create_table "roomsharing_applications", force: :cascade do |t|
    t.string   "ssn"
    t.string   "cell_phone"
    t.string   "other_phone"
    t.string   "email"
    t.string   "describe_pets"
    t.string   "num_roommates"
    t.string   "relationship_to_roommates"
    t.string   "facebook_profile_url"
    t.string   "twitter_profile_url"
    t.string   "linkedin_profile_url"
    t.string   "curr_street_address"
    t.string   "curr_apt_suite"
    t.string   "curr_city"
    t.string   "curr_zip"
    t.string   "curr_landlord_name"
    t.string   "curr_daytime_phone"
    t.string   "curr_evening_phone"
    t.string   "curr_rent_paid"
    t.string   "curr_tenancy_years"
    t.string   "curr_tenancy_months"
    t.string   "prev_street_address"
    t.string   "prev_apt_suite"
    t.string   "prev_city"
    t.string   "prev_zip"
    t.string   "prev_landlord_name"
    t.string   "prev_daytime_phone"
    t.string   "prev_evening_phone"
    t.string   "prev_rent_paid"
    t.string   "prev_tenancy_years"
    t.string   "prev_tenancy_months"
    t.string   "curr_annual_income"
    t.string   "curr_time_employed_years"
    t.string   "curr_time_employed_months"
    t.string   "curr_dates_employed"
    t.string   "prev_annual_income"
    t.string   "prev_time_employed_years"
    t.string   "prev_time_employed_months"
    t.string   "prev_dates_employed"
    t.boolean  "allow_background_authorization"
    t.boolean  "is_sight_unseen"
    t.boolean  "has_renters_insurace"
    t.string   "referral_source"
    t.boolean  "affiliate_sharing_ok"
    t.boolean  "received_disclosure"
    t.boolean  "accepts_terms"
    t.boolean  "approved"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "user_id"
    t.string   "f_name"
    t.string   "l_name"
    t.string   "listing_address"
    t.string   "listing_unit"
    t.string   "curr_state_abbrev"
    t.string   "prev_state_abbrev"
    t.string   "referenceId"
    t.string   "orderId"
    t.string   "orderStatus"
    t.date     "dob"
    t.string   "report_url"
    t.index ["user_id"], name: "index_roomsharing_applications_on_user_id", using: :btree
  end

  create_table "sales_amenities", force: :cascade do |t|
    t.string   "name"
    t.integer  "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sales_amenities_listings", id: false, force: :cascade do |t|
    t.integer "sales_listing_id"
    t.integer "sales_amenity_id"
  end

  create_table "sales_listings", force: :cascade do |t|
    t.integer  "beds"
    t.float    "baths"
    t.boolean  "tenant_occupied",           default: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "unit_id"
    t.string   "internal_notes"
    t.string   "public_description"
    t.string   "listing_type"
    t.float    "percent_commission"
    t.float    "outside_broker_commission"
    t.string   "seller_name"
    t.string   "seller_phone"
    t.string   "seller_address"
    t.string   "year_built"
    t.string   "building_type"
    t.integer  "lot_size"
    t.integer  "building_size"
    t.integer  "block_taxes"
    t.integer  "lot_taxes"
    t.integer  "water_sewer"
    t.integer  "insurance"
    t.string   "school_district"
    t.string   "certificate_of_occupancy"
    t.string   "violation_search"
    t.integer  "lock_version",              default: 0,     null: false
    t.integer  "floor"
    t.integer  "total_room_count"
    t.string   "condition"
    t.string   "showing_instruction"
    t.decimal  "commission_amount"
    t.boolean  "cyof",                      default: false
    t.date     "rented_date"
    t.boolean  "rlsny",                     default: false
    t.boolean  "share_with_brokers",        default: false
    t.boolean  "show",                      default: true
    t.boolean  "favorites",                 default: true
    t.boolean  "expose_address",            default: false
    t.index ["unit_id"], name: "index_sales_listings_on_unit_id", using: :btree
  end

  create_table "units", force: :cascade do |t|
    t.boolean  "archived",                       default: false
    t.integer  "listing_id"
    t.string   "building_unit"
    t.integer  "rent"
    t.datetime "available_by"
    t.string   "access_info"
    t.integer  "status",                         default: 0
    t.integer  "building_id"
    t.integer  "primary_agent_id"
    t.integer  "images_id"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "residential_listing_id"
    t.integer  "commercial_listing_id"
    t.string   "public_url"
    t.integer  "sales_listing_id"
    t.boolean  "exclusive"
    t.integer  "documents_id"
    t.integer  "primary_agent2_id"
    t.integer  "deals_id"
    t.integer  "open_houses_id"
    t.integer  "syndication_status",             default: 0
    t.boolean  "has_stock_photos",               default: false
    t.integer  "checkins_id"
    t.boolean  "is_exclusive_agreement_signed",  default: false
    t.integer  "feedback_id"
    t.datetime "exclusive_agreement_expires_at"
    t.index ["commercial_listing_id"], name: "index_units_on_commercial_listing_id", using: :btree
    t.index ["documents_id"], name: "index_units_on_documents_id", using: :btree
    t.index ["feedback_id"], name: "index_units_on_feedback_id", using: :btree
    t.index ["images_id"], name: "index_units_on_images_id", using: :btree
    t.index ["open_houses_id"], name: "index_units_on_open_houses_id", using: :btree
    t.index ["primary_agent2_id"], name: "index_units_on_primary_agent2_id", using: :btree
    t.index ["primary_agent_id"], name: "index_units_on_primary_agent_id", using: :btree
    t.index ["rent"], name: "index_units_on_rent", using: :btree
    t.index ["residential_listing_id"], name: "index_units_on_residential_listing_id", using: :btree
    t.index ["sales_listing_id"], name: "index_units_on_sales_listing_id", using: :btree
    t.index ["status"], name: "index_units_on_status", using: :btree
    t.index ["updated_at", "status", "archived"], name: "index_units_on_updated_at_and_status_and_archived", using: :btree
    t.index ["updated_at"], name: "index_units_on_updated_at", using: :btree
  end

  create_table "user_waterfalls", force: :cascade do |t|
    t.integer  "parent_agent_id"
    t.integer  "child_agent_id"
    t.integer  "level"
    t.float    "rate"
    t.boolean  "archived",             default: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "agent_seniority_rate"
  end

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
    t.string   "public_url"
    t.integer  "roommates_id"
    t.integer  "lock_version",        default: 0,     null: false
    t.integer  "announcements_id"
    t.integer  "deals_id"
    t.integer  "checkins_id"
    t.integer  "feedback_id"
    t.index ["announcements_id"], name: "index_users_on_announcements_id", using: :btree
    t.index ["auth_token"], name: "index_users_on_auth_token", using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["employee_title_id"], name: "index_users_on_employee_title_id", using: :btree
    t.index ["feedback_id"], name: "index_users_on_feedback_id", using: :btree
    t.index ["manager_id"], name: "index_users_on_manager_id", using: :btree
    t.index ["name"], name: "index_users_on_name", using: :btree
    t.index ["office_id"], name: "index_users_on_office_id", using: :btree
    t.index ["roommates_id"], name: "index_users_on_roommates_id", using: :btree
    t.index ["updated_at"], name: "index_users_on_updated_at", order: { updated_at: :desc }, using: :btree
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree
  end

  create_table "utilities", force: :cascade do |t|
    t.string   "name"
    t.integer  "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
