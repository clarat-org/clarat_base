class AddLabelToDivisionAndSplitBaseAndRenameDisplayName < ActiveRecord::Migration[5.1]
  def change
    add_column :divisions, :label, :string
    add_column :split_bases, :label, :string
    rename_column :locations, :display_name, :label
  end
end
