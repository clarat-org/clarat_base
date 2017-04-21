class AddTranslationToContactPeopleResponsibility < ActiveRecord::Migration
  def change

    create_table "contact_person_translations", force: true do |t|
      t.integer  "contact_person_id",              null: false
      t.string   "locale",                       null: false
      t.string   "source",          default: "", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "responsibility"
    end

    add_index "contact_person_translations", ["locale"], name: "index_contact_person_translations_on_locale"
    add_index "contact_person_translations", ["contact_person_id"], name: "index_contact_person_translations_on_contact_person_id"

  end
end
