# One of the main models. Represents the organizations that provide offers.
class Organization < ApplicationRecord
  has_paper_trail

  VISIBLE_FRONTEND_STATES = %w[approved all_done].freeze

  # Concerns
  include Assignable
  include Translation
  include Notable

  # Associations
  has_many :divisions, inverse_of: :organization, dependent: :destroy
  has_many :offers, through: :divisions, inverse_of: :organizations

  has_many :locations, inverse_of: :organization,
                       dependent: :restrict_with_exception
  belongs_to :website, inverse_of: :organizations
  has_many :contact_people, inverse_of: :organization, dependent: :destroy
  has_many :emails, through: :contact_people, inverse_of: :organizations
  has_many :sections, -> { distinct }, through: :divisions,
                                       inverse_of: :organizations
  has_and_belongs_to_many :filters
  has_and_belongs_to_many :umbrella_filters,
                          association_foreign_key: 'filter_id',
                          join_table: 'filters_organizations'
  has_many :cities, -> { distinct }, through: :locations,
                                     inverse_of: :organizations
  has_many :definitions_organizations, dependent: :destroy
  has_many :definitions, through: :definitions_organizations,
                         inverse_of: :organizations
  has_many :topics_organizations, dependent: :destroy
  has_many :topics, through: :topics_organizations
  has_many :offer_cities, -> { distinct }, through: :offers,
                                           class_name: 'City',
                                           source: 'city'
  has_many :division_cities, -> { distinct }, through: :divisions,
                                              class_name: 'City',
                                              source: 'city'

  # Enumerization
  extend Enumerize
  enumerize :legal_form, in: %w[ev ggmbh gag foundation gug gmbh ag ug kfm gbr
                                ohg kg eg sonstige state_entity]
  enumerize :mailings, in: %w[disabled enabled force_disabled]
  enumerize :pending_reason, in: %w[unstable on_hold foreign]

  # Sanitization
  extend Sanitization
  auto_sanitize :name # TODO: add to this list

  # Friendly ID
  extend FriendlyId
  friendly_id :name, use: [:slugged]

  # Translation
  translate :description

  # Scopes
  scope :visible_in_frontend, -> { where(aasm_state: VISIBLE_FRONTEND_STATES) }
  scope :created_at_day, ->(date) { where('created_at::date = ?', date) }
  scope :approved_at_day, ->(date) { where('approved_at::date = ?', date) }

  # # Custom Validations
  # validate :validate_hq_location, on: :update
  # validate :validate_websites_hosts
  # validate :must_have_umbrella_filter
  #
  # def validate_hq_location
  #   if locations.to_a.count(&:hq) != 1
  #     errors.add(:base, I18n.t('organization.validations.hq_location'))
  #   end
  # end
  #
  # def validate_websites_hosts
  #   websites.where.not(host: 'own').each do |website|
  #     errors.add(
  #       :base,
  #       I18n.t('organization.validations.website_host', website: website.url)
  #     )
  #   end
  # end
  #
  # def must_have_umbrella_filter
  #   if umbrella_filters.empty?
  #     fail_validation :umbrella_filters, 'needs_umbrella_filters'
  #   end
  # end

  # Methods

  # finds the main (HQ) location of this organization
  def location
    @location ||= locations.hq.first
  end

  alias homepage website # Deprecated

  def mailings_enabled?
    mailings == 'enabled'
  end

  def visible_in_frontend?
    VISIBLE_FRONTEND_STATES.include?(aasm_state)
  end

  def in_section? section
    divisions.joins(:section).where('sections.identifier = ?', section).count > 0
  end
end
