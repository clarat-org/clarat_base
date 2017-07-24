# Bounding Box around an area that a non-personal offer provides service to.
class Area < ApplicationRecord
  # Associations
  has_many :offers, inverse_of: :area
  # Validations moved to claradmin
end
