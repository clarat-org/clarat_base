class CreateSectionFilters < ActiveRecord::Migration
  class Offer < ActiveRecord::Base
    has_and_belongs_to_many :filters
    has_and_belongs_to_many :section_filters,
                            association_foreign_key: 'filter_id',
                            join_table: 'filters_offers'

    belongs_to :section_filter
  end

  class SectionFilter < ActiveRecord::Base
  end

  def up
    create_table :section_filters do |t|
      t.string :name
      t.string :identifier

      t.timestamps null: false
    end

    add_column :offers, :section_filter_id, :integer

    SectionFilter.create(name: 'Family', identifier: 'family')
    SectionFilter.create(name: 'Refugees', identifier: 'refugees')

    Offer.find_each do |offer|
      new_section =
        SectionFilter.find_by_identifier offer.section_filters.first.identifier
      offer.section_filter_id = new_section.id
    end
  end

  def down
    drop_table :section_filters
    remove_column :offers, :section_filter_id
  end
end
