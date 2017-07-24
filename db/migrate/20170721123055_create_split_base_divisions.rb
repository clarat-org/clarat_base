class CreateSplitBaseDivisions < ActiveRecord::Migration
  def change
    change_column :split_bases, :organization_id, :integer, null: true

    create_table :split_base_divisions do |t|
      t.integer 'split_base_id', null: false
      t.integer 'division_id', null: false

      t.timestamps
    end

    add_index :split_base_divisions, [:split_base_id]
    add_index :split_base_divisions, [:division_id]
  end
end
