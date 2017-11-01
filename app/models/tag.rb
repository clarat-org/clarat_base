# Used internally by researchers to provide extra searchable tags&keywords to offers.
class Tag < ApplicationRecord
  # Associations
  has_many :tags_offers
  has_many :offers, through: :tags_offers
  has_many :divisions_presumed_tags, inverse_of: :tag
  has_many :presuming_divisions,
           through: :divisions_presumed_tags, source: :division,
           inverse_of: :presumed_tags
end
