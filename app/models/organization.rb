# One of the main models. Represents the organizations that provide offers.
class Organization < ActiveRecord::Base
  has_paper_trail

  VISIBLE_FRONTEND_STATES = %w(approved all_done).freeze

  # Concerns
  include CustomValidatable, Notable, Translation

  # Associtations
  has_many :locations
  has_many :divisions, dependent: :destroy
  has_many :hyperlinks, as: :linkable, dependent: :destroy
  has_many :websites, through: :hyperlinks
  has_many :organization_offers, dependent: :destroy
  has_many :contact_people
  has_many :offers, through: :organization_offers, inverse_of: :organizations
  has_many :emails, through: :contact_people, inverse_of: :organizations
  has_many :sections, -> { uniq }, through: :offers
  has_many :split_bases, inverse_of: :organization
  has_and_belongs_to_many :filters
  has_and_belongs_to_many :umbrella_filters,
                          association_foreign_key: 'filter_id',
                          join_table: 'filters_organizations'
  has_many :cities, -> { uniq }, through: :locations,
                                 inverse_of: :organizations
  has_many :definitions_organizations
  has_many :definitions, through: :definitions_organizations


  # Enumerization
  extend Enumerize
  enumerize :legal_form, in: %w(ev ggmbh gag foundation gug gmbh ag ug kfm gbr
                                ohg kg eg sonstige state_entity)
  enumerize :mailings, in: %w(disabled enabled force_disabled)

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

  # Validations
  validates :name, length: { maximum: 100 }, presence: true, uniqueness: true
  validates :description, presence: true
  validates :legal_form, presence: true
  validates :founded, length: { is: 4 }, allow_blank: true
  validates :slug, uniqueness: true
  validates :mailings, presence: true
  # Custom Validations
  validate :validate_hq_location, on: :update
  validate :validate_websites_hosts
  validate :must_have_umbrella_filter

  def validate_hq_location
    if locations.to_a.count(&:hq) != 1
      errors.add(:base, I18n.t('organization.validations.hq_location'))
    end
  end

  def validate_websites_hosts
    websites.where.not(host: 'own').each do |website|
      errors.add(
        :base,
        I18n.t('organization.validations.website_host', website: website.url)
      )
    end
  end

  def must_have_umbrella_filter
    if umbrella_filters.empty?
      fail_validation :umbrella_filters, 'needs_umbrella_filters'
    end
  end

  # Methods

  # finds the main (HQ) location of this organization
  def location
    @location ||= locations.hq.first
  end

  def homepage
    websites.find_by_host('own')
  end

  def mailings_enabled?
    mailings == 'enabled'
  end

  def visible_in_frontend?
    VISIBLE_FRONTEND_STATES.include?(aasm_state)
  end

  def in_section? section
    sections.where(identifier: section).count > 0
  end
end
