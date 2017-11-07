# Connector model
class OfferDivision < ApplicationRecord
  belongs_to :offer, inverse_of: :offer_divisions
  belongs_to :division, inverse_of: :offer_divisions
end
