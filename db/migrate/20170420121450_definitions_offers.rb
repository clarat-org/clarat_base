class DefinitionsOffers < ActiveRecord::Migration
  def change
    create_table "definitions_offers", force: true do |t|
      t.integer  "definition_id",              null: false
      t.integer  "offer_id",              null: false
    end

    add_index "definitions_offers", ["definition_id"], name: "index_definitions_offers_on_definition_id", using: :btree
    add_index "definitions_offers", ["offer_id"], name: "index_definitions_offers_on_offer_id", using: :btree
  end
end
