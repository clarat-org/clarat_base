class AddKewordsToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :keywords_de, :text
    add_column :categories, :keywords_en, :text
    add_column :categories, :keywords_fr, :text
    add_column :categories, :keywords_pl, :text
    add_column :categories, :keywords_ru, :text
    add_column :categories, :keywords_ar, :text
    add_column :categories, :keywords_fa, :text
    add_column :categories, :keywords_tr, :text
  end
end
