class SectionFilter < ActiveRecord::Base
  has_many :offers
  has_many :organizations, through: :offers
  has_many :target_audience_filters
  has_many :divisions, inverse_of: :section_filter
  has_many :categories_section_filters
  has_many :categories, through: :categories_section_filters
end
