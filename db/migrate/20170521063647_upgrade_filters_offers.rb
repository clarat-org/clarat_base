class UpgradeFiltersOffers < ActiveRecord::Migration
  def change
    create_table :target_audience_filters_offers, force: true do |t|
      t.integer "target_audience_filter_id", null: false
      t.integer "offer_id",  null: false
      t.string "residency_status"
      t.string "gender_first_part_of_stamp"
      t.string "gender_second_part_of_stamp"
      t.string "addition"
      t.integer "age_from"
      t.integer "age_to"
      t.boolean "age_visible", default: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "stamp_de"
      t.string "stamp_en"
      t.string "stamp_de"
      t.string "stamp_ar"
      t.string "stamp_fa"
      t.string "stamp_fr"
      t.string "stamp_tr"
      t.string "stamp_ru"
      t.string "stamp_pl"
    end

    add_index "target_audience_filters_offers", ["target_audience_filter_id"], name: "index_ta_filters_offers_on_target_audience_filter_id", using: :btree
    add_index "target_audience_filters_offers", ["offer_id"], name: "index_target_audience_filters_offers_on_offer_id", using: :btree
  end
end
