# Internal dictionary: Definitions for certain words get automatically
# infused into the texts of other models.
class Definition < ApplicationRecord
  # Associations
  has_many :definitions_organizations, dependent: :destroy
  has_many :organizations, through: :definitions_organizations,
                           inverse_of: :definitions
  has_many :definitions_offers, dependent: :destroy
  has_many :offers, through: :definitions_offers,
                    inverse_of: :definitions

  # Validations
  validates :key, presence: true, uniqueness: true,
                  exclusion: { in: %w[dfn class JS tooltip data id] },
                  length: { maximum: 400 }
  validates :explanation, presence: true, length: { maximum: 500 }
end
