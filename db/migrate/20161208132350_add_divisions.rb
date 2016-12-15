class AddDivisions < ActiveRecord::Migration
  def change
    create_table :divisions do |t|
      t.string 'name', null: false
      t.text 'description', null: true

      t.integer 'organization_id', null: false
      t.integer 'section_filter_id', null: false

      t.timestamps null: false
    end
    add_index :divisions, [:organization_id],
              name: 'index_divisions_on_organization_id', using: :btree
  end
end
