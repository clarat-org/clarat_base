class ChangeAgeInTargetAudienceFiltersOffer < ActiveRecord::Migration
  def up
    change_column :target_audience_filters_offers, :age_from, :integer, null: false, default: 0
    change_column :target_audience_filters_offers, :age_to, :integer, null: false, default: 99
  end
  def down
    change_column :target_audience_filters_offers, :age_from, :integer, null: true
    change_column :target_audience_filters_offers, :age_to, :integer, null: true
  end
end
