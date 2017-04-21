class ContactPersonTranslation < ActiveRecord::Base
  include BaseTranslation

  # Concerns
  include Assignable

  # Associations
  belongs_to :contact_person, inverse_of: :translations
  alias translated_model contact_person

  # Methods
  def self.translated_class
    ContactPerson
  end
end
