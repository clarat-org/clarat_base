# Connector Model Category <-> Offers
class CategoriesOffer < ApplicationRecord
  # Associations
  belongs_to :offer, inverse_of: :categories_offers
  belongs_to :category, inverse_of: :categories_offers
end
