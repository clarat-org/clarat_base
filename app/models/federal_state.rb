# Normalization of (German) federal states.
class FederalState < ActiveRecord::Base
  # Associations
  has_many :locations, inverse_of: :federal_state

  # Validations moved to claradmin
end
