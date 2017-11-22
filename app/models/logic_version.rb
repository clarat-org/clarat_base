# Version of business-internal entry logic
class LogicVersion < ApplicationRecord
  # Associations
  has_many :offers, inverse_of: :logic_version,
                    dependent: :restrict_with_exception

  # Validations moved to claradmin
end
