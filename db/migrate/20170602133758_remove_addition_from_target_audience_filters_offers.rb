class RemoveAdditionFromTargetAudienceFiltersOffers < ActiveRecord::Migration
  def change
    remove_column :target_audience_filters_offers, :addition
  end
end
