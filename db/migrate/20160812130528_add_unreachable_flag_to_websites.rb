class AddUnreachableFlagToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :unreachable, :boolean, default: false
  end
end
