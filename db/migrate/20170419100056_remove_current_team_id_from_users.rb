class RemoveCurrentTeamIdFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :current_team_id
  end
end
