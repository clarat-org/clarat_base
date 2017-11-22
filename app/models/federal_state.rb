# Normalization of (German) federal states.
class FederalState < ApplicationRecord
  # Associations
  has_many :locations, inverse_of: :federal_state,
                       dependent: :restrict_with_exception

  # Validations moved to claradmin
end
