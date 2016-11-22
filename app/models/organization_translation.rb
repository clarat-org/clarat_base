class OrganizationTranslation < ActiveRecord::Base
  include BaseTranslation

  # Concerns
  include Assignable

  # Associations
  belongs_to :organization, inverse_of: :translations
  has_many :section_filters, through: :organization
end
