class RemoveExclusiveGenderFromOffers < ActiveRecord::Migration
  def change
    remove_column :offers, :exclusive_gender, :string
  end
end
