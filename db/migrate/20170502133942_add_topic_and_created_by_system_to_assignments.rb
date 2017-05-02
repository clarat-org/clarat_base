class AddTopicAndCreatedBySystemToAssignments < ActiveRecord::Migration
  def up
    add_column :assignments, :topic, :string, :null => true
    add_column :assignments, :created_by_system, :boolean, default: false
  end
  def down
    remove_column :assignments, :topic
    remove_column :assignments, :created_by_system
  end
end
