# Polymorphic join model between organizations/offers and websites.
class Division < ActiveRecord::Base
  # associtations
  belongs_to :organization, inverse_of: :divisions
  belongs_to :section, inverse_of: :divisions
end
