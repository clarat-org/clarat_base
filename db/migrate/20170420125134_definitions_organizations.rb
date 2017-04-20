class DefinitionsOrganizations < ActiveRecord::Migration
  def change
    create_table "definitions_organizations", force: true do |t|
      t.integer  "definition_id",              null: false
      t.integer  "organization_id",              null: false
    end

    add_index "definitions_organizations", ["definition_id"], name: "index_definitions_organizations_on_definition_id", using: :btree
    add_index "definitions_organizations", ["organization_id"], name: "index_definitions_organizations_on_organization_id", using: :btree
  end
end
