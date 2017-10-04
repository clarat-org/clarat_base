# Used internally by researchers to provide extra searchable tags&keywords to offers.
class Tag < ApplicationRecord
  # Associations
  has_many :tags_offers
  has_many :offers, through: :tags_offers
end
