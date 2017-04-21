class RemoveLegalInformationFromOffers < ActiveRecord::Migration
  def change
    remove_column :offers, :legal_information
  end
end
