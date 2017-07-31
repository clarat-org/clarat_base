class Section < ActiveRecord::Base
  has_many :offers
  has_many :organizations, -> { uniq }, through: :offers, inverse_of: :sections
  has_many :target_audience_filters, inverse_of: :section
  has_many :divisions, inverse_of: :section
  has_many :categories_sections
  has_many :categories, through: :categories_sections
  has_many :cities, -> { uniq }, through: :offers, inverse_of: :sections

  IDENTIFIER = %w(family refugees).freeze
end
