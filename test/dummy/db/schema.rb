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

ActiveRecord::Schema.define(version: 20160104142514) do

  create_table "areas", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.float    "minlat",                 null: false
    t.float    "maxlat",                 null: false
    t.float    "minlong",                null: false
    t.float    "maxlong",                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name",       limit: 255,                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "icon",       limit: 12
    t.integer  "parent_id"
    t.integer  "sort_order"
    t.boolean  "visible",                default: true
  end

  add_index "categories", ["name"], name: "index_categories_on_name"

  create_table "categories_filters", id: false, force: :cascade do |t|
    t.integer "filter_id",   null: false
    t.integer "category_id", null: false
  end

  add_index "categories_filters", ["category_id"], name: "index_filters_categories_on_category_id"
  add_index "categories_filters", ["filter_id"], name: "index_filters_categories_on_filter_id"

  create_table "categories_offers", id: false, force: :cascade do |t|
    t.integer "offer_id",    null: false
    t.integer "category_id", null: false
  end

  add_index "categories_offers", ["category_id"], name: "index_categories_offers_on_category_id"
  add_index "categories_offers", ["offer_id"], name: "index_categories_offers_on_offer_id"

  create_table "category_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
  end

  add_index "category_hierarchies", ["ancestor_id", "descendant_id", "generations"], name: "category_anc_desc_idx", unique: true
  add_index "category_hierarchies", ["descendant_id"], name: "category_desc_idx"

  create_table "category_translations", force: :cascade do |t|
    t.integer  "category_id",              null: false
    t.string   "locale",                   null: false
    t.string   "source",      default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",        default: "", null: false
  end

  add_index "category_translations", ["category_id"], name: "index_category_translations_on_category_id"
  add_index "category_translations", ["locale"], name: "index_category_translations_on_locale"

  create_table "contact_people", force: :cascade do |t|
    t.integer  "organization_id",                              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "area_code_1",      limit: 6
    t.string   "local_number_1",   limit: 32
    t.string   "area_code_2",      limit: 6
    t.string   "local_number_2",   limit: 32
    t.string   "fax_area_code",    limit: 6
    t.string   "fax_number",       limit: 32
    t.string   "first_name",       limit: 255
    t.string   "last_name",        limit: 255
    t.string   "operational_name", limit: 255
    t.string   "academic_title",   limit: 255
    t.string   "gender",           limit: 255
    t.string   "responsibility",   limit: 255
    t.integer  "email_id"
    t.boolean  "spoc",                         default: false, null: false
  end

  add_index "contact_people", ["email_id"], name: "index_contact_people_on_email_id"
  add_index "contact_people", ["organization_id"], name: "index_contact_people_on_organization_id"

  create_table "contact_person_offers", force: :cascade do |t|
    t.integer "offer_id",          null: false
    t.integer "contact_person_id", null: false
  end

  add_index "contact_person_offers", ["contact_person_id"], name: "index_contact_person_offers_on_contact_person_id"
  add_index "contact_person_offers", ["offer_id"], name: "index_contact_person_offers_on_offer_id"

  create_table "contacts", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "email",      limit: 255
    t.text     "message"
    t.string   "url",        limit: 1000
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "definitions", force: :cascade do |t|
    t.string   "key",         limit: 255, null: false
    t.text     "explanation",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "emails", force: :cascade do |t|
    t.string   "address",       limit: 64,                        null: false
    t.string   "aasm_state",    limit: 32, default: "uninformed", null: false
    t.string   "security_code", limit: 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "federal_states", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "filters", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.string   "identifier", limit: 20,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",       limit: 255, null: false
  end

  create_table "filters_offers", id: false, force: :cascade do |t|
    t.integer "filter_id", null: false
    t.integer "offer_id",  null: false
  end

  add_index "filters_offers", ["filter_id"], name: "index_filters_offers_on_filter_id"
  add_index "filters_offers", ["offer_id"], name: "index_filters_offers_on_offer_id"

  create_table "hyperlinks", force: :cascade do |t|
    t.integer "linkable_id",              null: false
    t.string  "linkable_type", limit: 40, null: false
    t.integer "website_id",               null: false
  end

  add_index "hyperlinks", ["linkable_id", "linkable_type"], name: "index_hyperlinks_on_linkable_id_and_linkable_type"
  add_index "hyperlinks", ["website_id"], name: "index_hyperlinks_on_website_id"

  create_table "keywords", force: :cascade do |t|
    t.string "name",     limit: 255
    t.text   "synonyms"
  end

  create_table "keywords_offers", id: false, force: :cascade do |t|
    t.integer "keyword_id", null: false
    t.integer "offer_id",   null: false
  end

  add_index "keywords_offers", ["keyword_id"], name: "index_keywords_offers_on_keyword_id"
  add_index "keywords_offers", ["offer_id"], name: "index_keywords_offers_on_offer_id"

  create_table "locations", force: :cascade do |t|
    t.string   "street",           limit: 255,                null: false
    t.text     "addition"
    t.string   "zip",              limit: 255,                null: false
    t.string   "city",             limit: 255,                null: false
    t.boolean  "hq"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "organization_id",                             null: false
    t.integer  "federal_state_id",                            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",             limit: 255
    t.string   "display_name",     limit: 255,                null: false
    t.string   "area_code",        limit: 6
    t.string   "local_number",     limit: 32
    t.string   "email",            limit: 255
    t.boolean  "visible",                      default: true
  end

  add_index "locations", ["created_at"], name: "index_locations_on_created_at"
  add_index "locations", ["federal_state_id"], name: "index_locations_on_federal_state_id"
  add_index "locations", ["organization_id"], name: "index_locations_on_organization_id"

  create_table "notes", force: :cascade do |t|
    t.text     "text",                         null: false
    t.string   "topic",             limit: 32
    t.integer  "user_id",                      null: false
    t.integer  "notable_id",                   null: false
    t.string   "notable_type",      limit: 64, null: false
    t.integer  "referencable_id"
    t.string   "referencable_type", limit: 64
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["notable_id", "notable_type"], name: "index_notes_on_notable_id_and_notable_type"
  add_index "notes", ["referencable_id", "referencable_type"], name: "index_notes_on_referencable_id_and_referencable_type"
  add_index "notes", ["user_id"], name: "index_notes_on_user_id"

  create_table "offer_mailings", force: :cascade do |t|
    t.integer  "offer_id",                null: false
    t.integer  "email_id",                null: false
    t.string   "mailing_type", limit: 16, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "offer_mailings", ["email_id"], name: "index_offer_mailings_on_email_id"
  add_index "offer_mailings", ["offer_id"], name: "index_offer_mailings_on_offer_id"

  create_table "offer_translations", force: :cascade do |t|
    t.integer  "offer_id",                                      null: false
    t.string   "locale",                                        null: false
    t.string   "source",                           default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                  limit: 80, default: "", null: false
    t.text     "description",                      default: "", null: false
    t.text     "next_steps"
    t.text     "opening_specification"
  end

  add_index "offer_translations", ["locale"], name: "index_offer_translations_on_locale"
  add_index "offer_translations", ["offer_id"], name: "index_offer_translations_on_offer_id"

  create_table "offers", force: :cascade do |t|
    t.string   "name",                       limit: 120, null: false
    t.text     "description",                            null: false
    t.text     "next_steps"
    t.string   "encounter",                  limit: 255
    t.string   "slug",                       limit: 255
    t.integer  "location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "opening_specification"
    t.datetime "approved_at"
    t.text     "legal_information"
    t.integer  "created_by"
    t.integer  "approved_by"
    t.date     "expires_at",                             null: false
    t.integer  "area_id"
    t.text     "description_html"
    t.text     "next_steps_html"
    t.text     "opening_specification_html"
    t.string   "exclusive_gender",           limit: 255
    t.integer  "age_from"
    t.integer  "age_to"
    t.string   "target_audience",            limit: 255
    t.string   "aasm_state",                 limit: 32
  end

  add_index "offers", ["aasm_state"], name: "index_offers_on_aasm_state"
  add_index "offers", ["approved_at"], name: "index_offers_on_approved_at"
  add_index "offers", ["area_id"], name: "index_offers_on_area_id"
  add_index "offers", ["created_at"], name: "index_offers_on_created_at"
  add_index "offers", ["location_id"], name: "index_offers_on_location_id"

  create_table "offers_openings", id: false, force: :cascade do |t|
    t.integer "offer_id",   null: false
    t.integer "opening_id", null: false
  end

  add_index "offers_openings", ["offer_id"], name: "index_offers_openings_on_offer_id"
  add_index "offers_openings", ["opening_id"], name: "index_offers_openings_on_opening_id"

  create_table "openings", force: :cascade do |t|
    t.string   "day",        limit: 3,   null: false
    t.time     "open"
    t.time     "close"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_value"
    t.string   "name",       limit: 255, null: false
  end

  add_index "openings", ["day"], name: "index_openings_on_day"
  add_index "openings", ["name"], name: "index_openings_on_name"

  create_table "organization_offers", force: :cascade do |t|
    t.integer "offer_id",        null: false
    t.integer "organization_id", null: false
  end

  add_index "organization_offers", ["offer_id"], name: "index_organization_offers_on_offer_id"
  add_index "organization_offers", ["organization_id"], name: "index_organization_offers_on_organization_id"

  create_table "organization_translations", force: :cascade do |t|
    t.integer  "organization_id",              null: false
    t.string   "locale",                       null: false
    t.string   "source",          default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description",     default: "", null: false
  end

  add_index "organization_translations", ["locale"], name: "index_organization_translations_on_locale"
  add_index "organization_translations", ["organization_id"], name: "index_organization_translations_on_organization_id"

  create_table "organizations", force: :cascade do |t|
    t.string   "name",                   limit: 255,                 null: false
    t.text     "description",                                        null: false
    t.string   "legal_form",             limit: 255,                 null: false
    t.boolean  "charitable",                         default: false
    t.integer  "founded"
    t.string   "umbrella",               limit: 8
    t.string   "slug",                   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "approved_at"
    t.integer  "offers_count",                       default: 0
    t.integer  "locations_count",                    default: 0
    t.integer  "created_by"
    t.integer  "approved_by"
    t.boolean  "accredited_institution",             default: false
    t.text     "description_html"
    t.boolean  "mailings_enabled",                   default: false
    t.string   "aasm_state",             limit: 32
  end

  add_index "organizations", ["aasm_state"], name: "index_organizations_on_aasm_state"
  add_index "organizations", ["approved_at"], name: "index_organizations_on_approved_at"
  add_index "organizations", ["created_at"], name: "index_organizations_on_created_at"

  create_table "search_locations", force: :cascade do |t|
    t.string   "query",      limit: 255, null: false
    t.float    "latitude",               null: false
    t.float    "longitude",              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "geoloc",     limit: 35,  null: false
  end

  add_index "search_locations", ["geoloc"], name: "index_search_locations_on_geoloc"
  add_index "search_locations", ["query"], name: "index_search_locations_on_query"

  create_table "sitemaps", force: :cascade do |t|
    t.string "path",    limit: 255, null: false
    t.text   "content"
  end

  add_index "sitemaps", ["path"], name: "index_sitemaps_on_path", unique: true

  create_table "statistics", force: :cascade do |t|
    t.string  "topic",   limit: 40, null: false
    t.integer "user_id"
    t.date    "x",                  null: false
    t.integer "y",                  null: false
  end

  add_index "statistics", ["user_id"], name: "index_statistics_on_user_id"

  create_table "subscriptions", force: :cascade do |t|
    t.string   "email",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "update_requests", force: :cascade do |t|
    t.string   "search_location", limit: 255, null: false
    t.string   "email",           limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",              limit: 255, default: "",         null: false
    t.string   "encrypted_password", limit: 255, default: "",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",               limit: 255, default: "standard"
    t.integer  "failed_attempts",                default: 0,          null: false
    t.datetime "locked_at"
    t.string   "provider",           limit: 255
    t.string   "uid",                limit: 255
    t.string   "name",               limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      limit: 255, null: false
    t.integer  "item_id",                    null: false
    t.string   "event",          limit: 255, null: false
    t.string   "whodunnit",      limit: 255
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"

  create_table "websites", force: :cascade do |t|
    t.string   "host",       limit: 255, null: false
    t.string   "url",        limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "websites", ["host"], name: "index_websites_on_host"
  add_index "websites", ["url"], name: "index_websites_on_url"

end
