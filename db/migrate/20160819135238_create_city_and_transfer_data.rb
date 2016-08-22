class CreateCityAndTransferData < ActiveRecord::Migration
  class Location < ActiveRecord::Base
    validates :city, presence: true
  end

  def up
    # create new table
    create_table "cities", force: true do |t|
      t.string "name", null: false

      t.timestamps
    end

    # create current clarat cities
    big_cities = %w(Berlin Köln Düsseldorf München)
    big_cities.each do |big_city|
      City.create!(name: big_city)
    end

    # add column and index to location table
    add_column :locations, :city_id, :integer
    add_index "locations", ["city_id"], name: "index_locations_on_city_id", using: :btree

    # transfer current Data
    Location.find_each do |loc|
      # first search for big city in the name to remove things like 'Berlin-Wedding' and map it to 'Berlin'
      big_cities.each do |big_city|
        if loc.city.downcase.include?(big_city.downcase)
          city_id = City.find_by(name: big_city).id
          loc.update_columns city_id: city_id
        end
      end
      # check if city_id is still not set => use city String
      if !loc.city_id
        # search for city, if not yet existing => create it
        existing_city = City.find_by(name: loc.city)
        if !existing_city
          existing_city = City.create!(name: loc.city)
        end
        # connect location with city
        loc.update_columns city_id: existing_city.id
      end
    end

    # remove old city field
    remove_column :locations, :city, :string
  end


end
