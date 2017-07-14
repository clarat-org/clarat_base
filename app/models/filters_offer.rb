# Connector Model Offer <-> Filter
class FiltersOffer < ActiveRecord::Base
  # Associations
  belongs_to :filter, inverse_of: :filters_offers
  belongs_to :offer, inverse_of: :filters_offers

  # For rails_admin display
  # def name
  #   "#{filter ? filter.name : nil} (Offer##{offer ? offer.id : nil})"
  # end
end
