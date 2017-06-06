class Offer
  module Validations
    extend ActiveSupport::Concern

    included do
      validates :name, presence: true
      # TODO: replace with complicated custom validation OR save stamp text in model
      # validates :name,
      #           uniqueness: { scope: :location_id },
      #           unless: ->(offer) { offer.location.nil? }
      validates :description, presence: true
      validates :encounter, presence: true
      validates :expires_at, presence: true
      validates :code_word, length: { maximum: 140 }
      validates :section_id, presence: true
      validates_uniqueness_of :slug, scope: :section_id

      # Needs to be true before approval possible. Called in custom validation.
      # def before_approve
      #   TODO: Refactor age validations lead to simple HTML 5 checks which are
      #   eg not working in Safari. Also Rubocop complains...
      #   validate_associated_fields
      #   validate_target_audience
      # end
    end
  end
end
