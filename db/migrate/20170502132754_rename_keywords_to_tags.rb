class RenameKeywordsToTags < ActiveRecord::Migration
  def change
    rename_table :keywords, :tags
    rename_column :tags, :synonyms, :keywords_de
    rename_column :tags, :name, :name_de
    add_column :tags, :keywords_en, :text
    add_column :tags, :keywords_fr, :text
    add_column :tags, :keywords_pl, :text
    add_column :tags, :keywords_ru, :text
    add_column :tags, :keywords_ar, :text
    add_column :tags, :keywords_fa, :text
    add_column :tags, :keywords_tr, :text
    add_column :tags, :name_en, :string
    add_column :tags, :name_fr, :string
    add_column :tags, :name_pl, :string
    add_column :tags, :name_ru, :string
    add_column :tags, :name_ar, :string
    add_column :tags, :name_fa, :string
    add_column :tags, :name_tr, :string

    rename_table :keywords_offers, :tags_offers
    rename_column :tags_offers, :keyword_id, :tag_id
  end
end
