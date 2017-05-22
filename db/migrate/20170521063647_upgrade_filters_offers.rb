class UpgradeFiltersOffers < ActiveRecord::Migration
  def change
    add_column :filters_offers, :id, :primary_key
    add_column :filters_offers, :residency_status, :string
    add_column :filters_offers, :gender_first_part_of_stamp, :string
    add_column :filters_offers, :gender_second_part_of_stamp, :string
    add_column :filters_offers, :age_from, :integer
    add_column :filters_offers, :age_to, :integer
    add_column :filters_offers, :age_visible, :boolean, default: false
    add_column :filters_offers, :created_at, :datetime
    add_column :filters_offers, :updated_at, :datetime
  end
end
