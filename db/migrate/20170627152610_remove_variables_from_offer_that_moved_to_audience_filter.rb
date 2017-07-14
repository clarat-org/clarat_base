class RemoveVariablesFromOfferThatMovedToAudienceFilter < ActiveRecord::Migration
  def change
    remove_column :offers, :residency_status
    remove_column :offers, :age_to
    remove_column :offers, :age_from
    remove_column :offers, :age_visible
    remove_column :offers, :gender_first_part_of_stamp
    remove_column :offers, :gender_second_part_of_stamp
  end
end
