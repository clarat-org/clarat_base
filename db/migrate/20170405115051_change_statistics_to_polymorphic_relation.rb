class ChangeStatisticsToPolymorphicRelation < ActiveRecord::Migration
  def up
    add_column :statistics, :trackable_type, :string, null: true
    add_column :statistics, :trackable_id, :integer, null: true

    # convert existing statistics to user-statistics
    Statistic.find_each do |stat|
      stat.update_columns trackable_type: 'User', trackable_id: stat.user_id
    end

    add_index :statistics, [:trackable_id, :trackable_type]

    remove_column :statistics, :user_id
    remove_column :statistics, :user_team_id
  end

  def down
    add_column :statistics, :user_id, :integer
    add_column :statistics, :user_team_id, :integer

    Statistic.find_each do |stat|
      if(stat.trackable_type == 'User')
        stat.update_columns user_id: stat.trackable_id
      else
        stat.update_columns user_team_id: stat.trackable_id
      end
    end

    add_index :statistics, :user_id
    add_index :statistics, :user_team_id

    remove_column :statistics, :trackable_type
    remove_column :statistics, :trackable_id
  end
end
