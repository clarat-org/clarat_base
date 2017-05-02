# Internal dictionary: Definitions for certain words get automatically
# infused into the texts of other models.
class Definition < ActiveRecord::Base
  # Associations
  has_many :definitions_organizations
  has_many :organizations, through: :definitions_organizations
  has_many :definitions_offers
  has_many :offers, through: :definitions_offers

  # Validations
  validates :key, presence: true, uniqueness: true,
                  exclusion: { in: %w(dfn class JS tooltip data id) },
                  length: { maximum: 400 }
  validates :explanation, presence: true, length: { maximum: 500 }
end
