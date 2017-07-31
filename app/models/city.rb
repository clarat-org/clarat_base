# Simple City model - may be extended later.
class City < ActiveRecord::Base
  # Associations
  has_many :locations, inverse_of: :city
  has_many :divisions, inverse_of: :city
  has_many :offers, through: :locations, inverse_of: :city
  has_many :organizations, -> { uniq }, through: :locations,
                                        inverse_of: :cities

  # Validations moved to claradmin
end
