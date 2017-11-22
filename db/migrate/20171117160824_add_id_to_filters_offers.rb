class AddIdToFiltersOffers < ActiveRecord::Migration[5.1]
  def change
    add_column :filters_offers, :id, :primary_key
  end
end
