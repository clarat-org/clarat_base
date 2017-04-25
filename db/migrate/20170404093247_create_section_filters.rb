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

    fam_new = SectionFilter.find_by(identifier: 'family').nil? ? SectionFilter.create(name: 'Family', identifier: 'family') : SectionFilter.find_by(identifier: 'family')

    ref_new = SectionFilter.find_by(identifier: 'refugees').nil? ? SectionFilter.create(name: 'Refugees', identifier: 'refugees') : SectionFilter.find_by(identifier: 'refugees')

    Offer.find_each do |offer|
      new_id = offer.filters.where(type: 'SectionFilter').pluck(:identifier).include?('family') ? fam_new.id : ref_new.id
      offer.update_columns section_filter_id: new_id
    end
  end

  def down
    drop_table :section_filters
    remove_column :offers, :section_filter_id
  end
end
