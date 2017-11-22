class AddIdToDivisionsPresumedTags < ActiveRecord::Migration[5.1]
  def change
    add_column :divisions_presumed_tags, :id, :primary_key
  end
end
