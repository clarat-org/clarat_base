class AddIdToDivisionsPresumedSolutionCategories < ActiveRecord::Migration[5.1]
  def change
    add_column :divisions_presumed_solution_categories, :id, :primary_key
  end
end
