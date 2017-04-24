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
  TREATMENT_TYPES = %w(in-patient semi-residential out-patient).freeze
  PARTICIPANT_STRUCTURES =
    %w(target_audience_alone
       target_audience_in_group_with_others_with_different_problems
       target_audience_in_group_with_others_with_same_problem).freeze
  EXCLUSIVE_GENDERS = %w(female male).freeze
  STAMP_SECOND_PART_GENDERS = %w(female male neutral).freeze
  # ^ nil means inclusive to any gender
  CONTACT_TYPES = %w(personal remote).freeze
  RESIDENCY_STATUSES =
    %w(before_the_asylum_decision with_a_residence_permit
       with_temporary_suspension_of_deportation
       with_deportation_decision).freeze
  VISIBLE_FRONTEND_STATES = %w(approved expired).freeze

  enumerize :encounter, in: ENCOUNTERS
  enumerize :gender_first_part_of_stamp, in: EXCLUSIVE_GENDERS
  enumerize :gender_second_part_of_stamp, in: STAMP_SECOND_PART_GENDERS
  enumerize :treatment_type, in: TREATMENT_TYPES
  enumerize :participant_structure, in: PARTICIPANT_STRUCTURES
  enumerize :residency_status, in: RESIDENCY_STATUSES

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

  # stamp-generation methods for each section
  def stamp_family locale
    Offerstamp.generate_stamp self, 'family', locale
  end

  def stamp_refugees locale
    Offerstamp.generate_stamp self, 'refugees', locale
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
