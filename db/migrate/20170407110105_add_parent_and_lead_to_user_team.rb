class AddParentAndLeadToUserTeam < ActiveRecord::Migration
  def up
    add_column :user_teams, :lead_id, :integer
    add_column :user_teams, :parent_id, :integer

    add_index :user_teams, [:lead_id]
    add_index :user_teams, [:parent_id]
  end

  def down
    remove_column :user_teams, :lead_id
    remove_column :user_teams, :parent_id
  end
end
