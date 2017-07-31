class AddCityIdAreaIdObservingUsersAndPendingReason < ActiveRecord::Migration
  def change
    add_column :divisions, :city_id, :integer
    add_column :divisions, :area_id, :integer
    add_column :organizations, :pending_reason, :string

    create_table :user_team_observing_users do |t|
      t.integer 'user_id', null: false
      t.integer 'user_team_id', null: false

      t.timestamps
    end

    add_index :divisions, [:city_id]
    add_index :divisions, [:area_id]
    add_index :user_team_observing_users, [:user_id]
    add_index :user_team_observing_users, [:user_team_id]
  end
end
