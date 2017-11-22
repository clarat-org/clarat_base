class DropSplitBases < ActiveRecord::Migration[5.1]
  def change
    drop_table :split_bases
    remove_column :offers, :split_base_id
    drop_table :split_base_divisions
  end
end
