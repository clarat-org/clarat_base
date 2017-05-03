# Used internally by researchers to provide extra searchable tags&keywords to offers.
class Tag < ActiveRecord::Base
  # associtations
  has_many :tags_offers
  has_many :offers, through: :tags_offers

  # Validations
  validates :name_de, uniqueness: true, presence: true
  validates :name_en, uniqueness: true, presence: true
end
