class AddIdToTagsOffers < ActiveRecord::Migration[5.1]
  def change
    add_column :tags_offers, :id, :primary_key
  end
end
