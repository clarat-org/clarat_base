class AddKewordsToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :keywords_de, :text
    add_column :categories, :keywords_en, :text
    add_column :categories, :keywords_ar, :text
    add_column :categories, :keywords_fa, :text
  end
end
