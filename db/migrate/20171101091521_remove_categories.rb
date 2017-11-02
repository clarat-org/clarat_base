class RemoveCategories < ActiveRecord::Migration[5.1]
  def change
    if ActiveRecord::Base.connection.table_exists? 'categories'
      drop_table :categories
    end
    if ActiveRecord::Base.connection.table_exists? 'categories_offers'
      drop_table :categories_offers
    end
    if ActiveRecord::Base.connection.table_exists? 'categories_sections'
      drop_table :categories_sections
    end
    if ActiveRecord::Base.connection.table_exists? 'category_hierarchies'
      drop_table :category_hierarchies
    end
    if ActiveRecord::Base.connection.table_exists? 'divisions_presumed_categories'
      drop_table :divisions_presumed_categories
    end
  end
end
