class Offer
  module Associations
    extend ActiveSupport::Concern

    included do
      # Associations
      belongs_to :location, inverse_of: :offers
      belongs_to :area, inverse_of: :offers
      belongs_to :solution_category, inverse_of: :offers
      belongs_to :logic_version, inverse_of: :offers
      belongs_to :split_base, inverse_of: :offers
      has_and_belongs_to_many :categories
      has_and_belongs_to_many :filters
      has_and_belongs_to_many :language_filters,
                              association_foreign_key: 'filter_id',
                              join_table: 'filters_offers'
      has_and_belongs_to_many :target_audience_filters,
                              association_foreign_key: 'filter_id',
                              join_table: 'filters_offers'
      has_and_belongs_to_many :trait_filters,
                              association_foreign_key: 'filter_id',
                              join_table: 'filters_offers'
      has_and_belongs_to_many :openings
      has_and_belongs_to_many :keywords, inverse_of: :offers
      has_many :contact_person_offers, inverse_of: :offer
      has_many :contact_people, through: :contact_person_offers,
                                inverse_of: :offers
      has_many :emails, through: :contact_people, inverse_of: :offers
      has_many :organization_offers, dependent: :destroy
      has_many :organizations, through: :organization_offers,
                               inverse_of: :offers
      has_many :next_steps_offers, inverse_of: :offer
      has_many :next_steps, through: :next_steps_offers, inverse_of: :offers
      # Attention: former has_one :organization, through: :locations
      # but there can also be offers without locations
      has_many :hyperlinks, as: :linkable, dependent: :destroy
      has_many :websites, through: :hyperlinks
      has_one :city, through: :location
      has_one :section_filter, through: :filter,
              association_foreign_key: 'filter_id',
              join_table: 'filters_offers'
    end
  end
end
