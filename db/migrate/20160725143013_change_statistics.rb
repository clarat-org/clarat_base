class ChangeStatistics < ActiveRecord::Migration
  def change
    rename_column :statistics, :x, :date
    rename_column :statistics, :y, :count
    reversible do |dir|
      dir.up do
        change_column :statistics, :count, :float, default: 0
        change_column :statistics, :topic, :string, null: true
      end
      dir.down do
        change_column :statistics, :count, :integer
        change_column :statistics, :topic, :string, limit: 40, null: false
      end
    end

    add_column :statistics, :user_team_id, :integer
    add_column :statistics, :model, :string
    add_column :statistics, :field_name, :string
    add_column :statistics, :field_start_value, :string
    add_column :statistics, :field_end_value, :string
    add_column :statistics, :time_frame, :string, default: 'daily'

    add_index :statistics, :user_team_id

    add_column :users, :current_team_id, :integer
    add_index :users, :current_team_id

    create_table :time_allocations do |t|
      t.integer :user_id, null: false
      t.integer :year, limit: 4, null: false
      t.integer :week_number, limit: 2, null: false
      t.integer :desired_wa_hours, limit: 3, null: false
      t.integer :actual_wa_hours, limit: 3
    end
    add_index :time_allocations, :user_id

    create_table :absences do |t|
      t.date :starts_at, null: false
      t.date :ends_at, null: false
      t.integer :user_id, null: false
      t.boolean :sync, default: true
    end
    add_index :absences, :user_id
  end
end
