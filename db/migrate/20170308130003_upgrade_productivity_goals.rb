class UpgradeProductivityGoals < ActiveRecord::Migration
  class ProductivityGoal < ActiveRecord::Base
  end

  def up
    ProductivityGoal.delete_all
    add_column :productivity_goals, :user_id, :integer
    add_index :productivity_goals, ['user_id']
    change_column :productivity_goals, :user_team_id, :integer, null: true

    remove_column :productivity_goals, :target_model
    remove_column :productivity_goals, :target_field_name
    remove_column :productivity_goals, :target_field_value
    remove_column :productivity_goals, :target_count

    rename_table :productivity_goals, :statistic_charts

    create_table :statistic_transitions do |t|
      t.string 'klass_name', null: false
      t.string 'field_name', null: false
      t.string 'start_value', null: false
      t.string 'end_value', null: false
    end

    create_table :statistic_chart_transitions, id: false do |t|
      t.integer :statistic_chart_id, null: false
      t.integer :statistic_transition_id, null: false
    end
    add_index :statistic_chart_transitions, ['statistic_chart_id']
    add_index :statistic_chart_transitions, ['statistic_transition_id']

    create_table :statistic_goals do |t|
      t.integer 'amount', null: false
      t.date 'starts_at', null: false
    end

    create_table :statistic_chart_goals, id: false do |t|
      t.integer :statistic_chart_id, null: false
      t.integer :statistic_goal_id, null: false
    end
    add_index :statistic_chart_goals, ['statistic_chart_id']
    add_index :statistic_chart_goals, ['statistic_goal_id']
  end

  def down
    rename_table :statistic_charts, :productivity_goals
    ProductivityGoal.delete_all

    remove_column :productivity_goals, :user_id
    change_column :productivity_goals, :user_team_id, :integer, null: false

    add_column :productivity_goals, :target_model, :string
    change_column :productivity_goals, :target_model, :string, null: false
    add_column :productivity_goals, :target_field_name, :string
    change_column :productivity_goals, :target_field_name, :string, null: false
    add_column :productivity_goals, :target_field_value, :string
    change_column :productivity_goals, :target_field_value, :string, null: false
    add_column :productivity_goals, :target_count, :string
    change_column :productivity_goals, :target_count, :string, null: false

    drop_table :statistic_transitions
    drop_table :statistic_chart_transitions
    drop_table :statistic_goals
    drop_table :statistic_chart_goals
  end
end
