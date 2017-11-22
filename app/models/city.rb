# Simple City model - may be extended later.
class City < ApplicationRecord
  # Associations
  has_many :locations, inverse_of: :city, dependent: :restrict_with_exception
  has_many :divisions, inverse_of: :city, dependent: :restrict_with_exception
  has_many :offers, through: :locations, inverse_of: :city
  has_many :organizations, -> { distinct }, through: :locations,
                                            inverse_of: :cities
  has_many :sections, -> { distinct }, through: :offers, inverse_of: :cities
end
