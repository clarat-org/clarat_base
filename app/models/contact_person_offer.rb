# Connector Model ContactPeople <-> Offers
class ContactPersonOffer < ActiveRecord::Base
  # Associations
  belongs_to :offer, inverse_of: :contact_person_offers
  belongs_to :contact_person, inverse_of: :contact_person_offers

  # Validations
  validates :offer_id, presence: true, uniqueness: {
    scope: :contact_person_id
  }
  validates :contact_person_id, presence: true, uniqueness: {
    scope: :offer_id
  }
end
