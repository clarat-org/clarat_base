class OfferTranslation < ActiveRecord::Base
  include BaseTranslation

  # Concerns
  include Assignable

  # Associations
  belongs_to :offer, inverse_of: :translations
  has_many :section_filters, through: :offer
end
