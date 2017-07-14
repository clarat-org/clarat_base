# One of the main models. The offers that visitors want to find.
# Has modules in offer subfolder.
class Offer < ActiveRecord::Base
  has_paper_trail

  # Modules
  include Validations, CustomValidations, Associations, Search

  # Concerns
  include CustomValidatable, Notable, Translation

  # Enumerization
  extend Enumerize
  ENCOUNTERS =
    %w(personal hotline email chat forum online-course portal).freeze
  CONTACT_TYPES = %w(personal remote).freeze
  VISIBLE_FRONTEND_STATES = %w(approved expired).freeze
  enumerize :encounter, in: ENCOUNTERS

  # NOTE: moved to FiltersOffer! Only keep this here until the data fields can
  # be removed from the offer-table
  # RESIDENCY_STATUSES =
  #   %w(before_the_asylum_decision with_a_residence_permit
  #      with_temporary_suspension_of_deportation
  #      with_deportation_decision).freeze
  # EXCLUSIVE_GENDERS = %w(female male).freeze
  # STAMP_SECOND_PART_GENDERS = %w(female male neutral).freeze
  # # ^ nil means inclusive to any gender
  # enumerize :gender_first_part_of_stamp, in: EXCLUSIVE_GENDERS
  # enumerize :gender_second_part_of_stamp, in: STAMP_SECOND_PART_GENDERS
  # enumerize :residency_status, in: RESIDENCY_STATUSES

  # Friendly ID
  extend FriendlyId
  friendly_id :slug_candidates, use: :scoped, scope: :section

  # Translation
  translate :name, :description, :old_next_steps, :opening_specification

  def slug_candidates
    [
      :name,
      [:name, :location_zip]
    ]
  end

  # Scopes
  scope :visible_in_frontend, -> { where(aasm_state: VISIBLE_FRONTEND_STATES) }
  scope :created_at_day, ->(date) { where('created_at::date = ?', date) }
  scope :approved_at_day, ->(date) { where('approved_at::date = ?', date) }
  scope :in_section, lambda { |section|
    joins(:section).where('sections.identifier = ?', section)
  }

  # Methods

  delegate :name, :street, :addition, :city, :zip, :address,
           to: :location, prefix: true, allow_nil: true

  delegate :minlat, :maxlat, :minlong, :maxlong,
           to: :area, prefix: true, allow_nil: true

  def organization_count
    organizations.count
  end

  def next_steps_for_current_locale
    next_steps_for_locale I18n.locale
  end

  def next_steps_for_locale locale
    next_steps.select("text_#{locale}").map(&:"text_#{locale}").join(' ')
  end

  def in_section? section_identifier
    section.identifier == section_identifier
  end

  def opening_details?
    !openings.blank? || !opening_specification.blank?
  end

  def visible_in_frontend?
    VISIBLE_FRONTEND_STATES.include?(aasm_state)
  end
end
