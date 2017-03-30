class AddResidencyStatusToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :residency_status, :string, null: true
  end
end
