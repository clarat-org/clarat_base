# Used internally by researchers to provide extra searchable tags&keywords to offers.
class Tag < ActiveRecord::Base
  # Associations
  has_many :tags_offers
  has_many :offers, through: :tags_offers

  # Validations
  validates :name_de, uniqueness: true, presence: true
  validates :name_en, uniqueness: true, presence: true
  validates :explanations_de, length: { maximum: 500 }
  validates :explanations_en, length: { maximum: 500 }
  validates :explanations_ar, length: { maximum: 500 }
  validates :explanations_fa, length: { maximum: 500 }
end
