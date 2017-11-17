class Offer
  module Associations
    extend ActiveSupport::Concern

    included do
      # Associations
      belongs_to :split_base, inverse_of: :offers, optional: true
      has_many :offer_divisions, inverse_of: :offer,
                                 dependent: :destroy
      has_many :divisions, through: :offer_divisions,
                           inverse_of: :offers,
                           source: 'division'
      # has_many :divisions, through: :split_base,
      #                      inverse_of: :offers
      has_many :organizations, through: :divisions,
                               inverse_of: :offers

      belongs_to :location, inverse_of: :offers
      belongs_to :area, inverse_of: :offers
      belongs_to :solution_category, inverse_of: :offers
      belongs_to :logic_version, inverse_of: :offers

      has_many :filters_offers
      has_many :filters, through: :filters_offers, source: :filter
      belongs_to :section, inverse_of: :offers, optional: true
      has_many :language_filters,
               class_name: 'LanguageFilter',
               through: :filters_offers,
               source: :filter,
               inverse_of: :offers
      has_many :trait_filters,
               class_name: 'TraitFilter',
               through: :filters_offers,
               source: :filter,
               inverse_of: :offers

      has_many :target_audience_filters_offers,
               dependent: :destroy, inverse_of: :offer
      has_many :target_audience_filters,
               class_name: 'TargetAudienceFilter',
               through: :target_audience_filters_offers,
               source: :target_audience_filter,
               inverse_of: :offers

      has_many :tags_offers, inverse_of: :offer, dependent: :destroy
      has_many :tags, through: :tags_offers, inverse_of: :offers
      has_and_belongs_to_many :openings, inverse_of: :offers
      has_many :contact_person_offers, inverse_of: :offer,
                                       dependent: :destroy
      has_many :contact_people, through: :contact_person_offers,
                                inverse_of: :offers
      has_many :emails, through: :contact_people, inverse_of: :offers
      has_many :next_steps_offers, inverse_of: :offer,
                                   dependent: :destroy
      has_many :next_steps, through: :next_steps_offers, inverse_of: :offers
      # Attention: former has_one :organization, through: :locations
      # but there can also be offers without locations
      has_many :hyperlinks, as: :linkable, dependent: :destroy
      has_many :websites, through: :hyperlinks, inverse_of: :offers
      has_one :city, through: :location, inverse_of: :offers
      has_many :definitions_offers, inverse_of: :offer,
                                    dependent: :destroy
      has_many :definitions, through: :definitions_offers, inverse_of: :offers
    end
  end
end
