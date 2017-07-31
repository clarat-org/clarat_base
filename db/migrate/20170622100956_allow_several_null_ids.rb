class AllowSeveralNullIds < ActiveRecord::Migration
  def up
    change_column :contact_people, :organization_id, :integer, null: true
    change_column :locations, :organization_id, :integer, null: true
  end

  def down
    change_column :contact_people, :organization_id, :integer, null: false
    change_column :locations, :organization_id, :integer, null: false
  end
end
