class AddSectionFilterIdToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :section_filter_id, :integer
  end
end
