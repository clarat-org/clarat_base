class AddDescriptionToLogicVersion < ActiveRecord::Migration
  def change
    add_column :logic_versions, :description, :text
  end
end
