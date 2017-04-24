class OfferTranslation < ActiveRecord::Base
  include BaseTranslation

  # Concerns
  include Assignable

  # Associations
  belongs_to :offer, inverse_of: :translations
  has_one :section, through: :offer

  alias translated_model offer

  # Methods
  def self.translated_class
    Offer
  end
end
