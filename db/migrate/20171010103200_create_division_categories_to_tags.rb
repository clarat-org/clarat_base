class CreateDivisionCategoriesToTags < ActiveRecord::Migration[5.1]
  def change
    create_table :divisions_presumed_tags, id: false do |t|
      t.integer "division_id", null: false
      t.integer "tag_id", null: false
      t.index ["division_id"], name: "index_divisions_presumed_tags_on_division_id"
      t.index ["tag_id"], name: "index_divisions_presumed_tags_on_tag_id"
    end
  end
end
