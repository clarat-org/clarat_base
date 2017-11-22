# Bounding Box around an area that a non-personal offer provides service to.
class Area < ApplicationRecord
  # Associations
  has_many :offers, inverse_of: :area, dependent: :restrict_with_exception
  has_many :divisions, inverse_of: :area, dependent: :restrict_with_exception
  # Validations moved to claradmin
end
