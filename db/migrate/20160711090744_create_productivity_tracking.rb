class CreateProductivityTracking < ActiveRecord::Migration
  def change
    create_table 'user_teams' do |t|
      t.string 'name', null: false
    end

    create_table 'user_team_users' do |t|
      t.integer 'user_team_id'
      t.integer 'user_id'

      t.index 'user_team_id'
      t.index 'user_id'
    end

    create_table 'productivity_goals' do |t|
      t.string 'title', null: false
      t.date 'starts_at', null: false
      t.date 'ends_at', null: false
      t.string 'target_model', null: false
      t.integer 'target_count', null: false
      t.string 'target_field_name', null: false
      t.string 'target_field_value', null: false
      t.integer 'user_team_id', null: false

      t.index 'user_team_id'
    end
  end
end
