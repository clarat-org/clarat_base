# A building block to form the "next steps" description for Offers
class NextStep < ApplicationRecord
  # Associations
  has_many :next_steps_offers, inverse_of: :next_step, dependent: :destroy
  has_many :offers, through: :next_steps_offers, inverse_of: :next_steps

  # Validations moved to claradmin

  # Methods

  # locale-specific text getter with two fallbacks
  def text(locale = I18n.locale)
    output = send(:"text_#{locale}")
    output = output.blank? ? text_en : output
    output.blank? ? text_de : output
  end
end
