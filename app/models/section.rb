class Section < ApplicationRecord
  has_many :offers
  has_many :divisions, inverse_of: :section
  has_many :organizations, -> { distinct },
           through: :divisions, inverse_of: :sections
  has_many :target_audience_filters, inverse_of: :section
  has_many :cities, -> { distinct }, through: :offers, inverse_of: :sections

  IDENTIFIER = %w[family refugees].freeze
end
