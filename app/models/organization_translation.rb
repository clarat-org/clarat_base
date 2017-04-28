class OrganizationTranslation < ActiveRecord::Base
  include BaseTranslation

  # Concerns
  include Assignable

  # Associations
  belongs_to :organization, inverse_of: :translations
  has_many :sections, through: :organization

  alias translated_model organization

  # Methods
  def self.translated_class
    Organization
  end
end
