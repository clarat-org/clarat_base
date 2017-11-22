class AddIdToOffersOpenings < ActiveRecord::Migration[5.1]
  def change
    add_column :offers_openings, :id, :primary_key
  end
end
