class AddExplanationsToTagsAndCategories < ActiveRecord::Migration
  def change
    add_column :categories, :explanations_de, :text
    add_column :categories, :explanations_en, :text
    add_column :categories, :explanations_ar, :text
    add_column :categories, :explanations_fa, :text
    add_column :tags, :explanations_de, :text
    add_column :tags, :explanations_en, :text
    add_column :tags, :explanations_ar, :text
    add_column :tags, :explanations_fa, :text
  end
end
