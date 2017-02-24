class AddCityToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :city, :string, :null => true
  end
end
