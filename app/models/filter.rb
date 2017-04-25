# STI parent model for different kinds of filters. Children located in the
# filters subfolder.
class Filter < ActiveRecord::Base
  extend Enumerize

  # Associtations
  has_and_belongs_to_many :offers
  has_and_belongs_to_many :organizations

  # Validations moved to claradmin
end
