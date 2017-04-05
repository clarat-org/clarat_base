class CategoriesSectionFilter < ActiveRecord::Base
	belongs_to :section_filter, inverse_of: :categories_section_filters
  belongs_to :category, inverse_of: :categories_section_filters
end