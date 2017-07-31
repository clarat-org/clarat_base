class AddMoreDataForOrgasAndDivisions < ActiveRecord::Migration
  class Organization < ActiveRecord::Base
  end

  def change
    create_table :divisions_presumed_categories, id: false do |t|
      t.integer :division_id, null: false
      t.integer :category_id, null: false
    end
    add_index :divisions_presumed_categories, ['division_id']
    add_index :divisions_presumed_categories, ['category_id']

    create_table :divisions_presumed_solution_categories, id: false do |t|
      t.integer :division_id, null: false
      t.integer :solution_category_id, null: false
    end
    add_index :divisions_presumed_solution_categories, ['division_id']
    add_index :divisions_presumed_solution_categories, ['solution_category_id'],
              name: 'index_presumed_s_categories_on_s_category' # max 62 chars

    add_column :organizations, :comment, :text
    add_column :divisions, :comment, :text
    add_column :divisions, :done, :boolean, default: false
    add_column :divisions, :size, :string, default: 'medium', null: false

    remove_column :divisions, :description, :text

    add_column :organizations, :website_id, :integer
    add_index :organizations, ['website_id']

    reversible do |direction|
      direction.up do
        change_column :organizations, :description, :text, null: true
        change_column :organizations, :legal_form, :text, null: true
      end
      direction.down do
        Organization.where('description IS NULL OR legal_form IS NULL')
          .delete_all
        change_column :organizations, :description, :text, null: false
        change_column :organizations, :legal_form, :text, null: false
      end
    end
  end
end
