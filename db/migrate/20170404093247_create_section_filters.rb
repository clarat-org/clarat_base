class CreateSectionFilters < ActiveRecord::Migration
  def change
    create_table :section_filters do |t|
      t.string :name
      t.string :identifier

      t.timestamps null: false
    end

    add_column :offers, :section_filter_id, :integer
  end
end
