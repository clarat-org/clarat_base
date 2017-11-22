class AddIdToFiltersOrganizations < ActiveRecord::Migration[5.1]
  def change
    add_column :filters_organizations, :id, :primary_key
  end
end
