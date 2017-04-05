class FiltersOffer < ActiveRecord::Base
  belongs_to :offer, inverse_of: :filters_offers
  belongs_to :filter, inverse_of: :filters_offers
end