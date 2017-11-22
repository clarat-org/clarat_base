# Used internally by researchers to provide extra searchable
# tags&keywords to offers.
class Topic < ApplicationRecord
  # Associations
  has_many :topics_organizations, dependent: :destroy
  has_many :organizations, through: :topics_organizations
end
