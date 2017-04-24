class Section < ActiveRecord::Base
  has_many :offers
  has_many :organizations, through: :offers
  has_many :target_audience_filters
  has_many :divisions, inverse_of: :section
  has_many :categories_sections
  has_many :categories, through: :categories_sections

  IDENTIFIER = %w(family refugees).freeze
end
