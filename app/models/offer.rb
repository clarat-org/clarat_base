# One of the main models. The offers that visitors want to find.
# Has modules in offer subfolder.
class Offer < ActiveRecord::Base
  has_paper_trail

  # Modules
  include Validations, CustomValidations, Associations, Search, StateMachine

  # Concerns
  include Creator, CustomValidatable, Notable, Translation

  # Enumerization
  extend Enumerize
  ENCOUNTERS =
    %w(personal hotline email chat forum online-course portal fax letter).freeze
  TREATMENT_TYPES = %w(in-patient semi-residential out-patient).freeze
  PARTICIPANT_STRUCTURES =
    %w(target_audience_alone
       target_audience_in_group_with_others_with_different_problems
       target_audience_in_group_with_others_with_same_problem).freeze
  EXCLUSIVE_GENDERS = %w(boys_only girls_only).freeze
  BENEFICIARY_GENDERS = %w(female male).freeze
  STAMP_SECOND_PART_GENDERS = %w(female male neutral).freeze
  # ^ nil means inclusive to any gender
  CONTACT_TYPES = %w(personal remote).freeze
  RESIDENCE_STATUSES =
    %w(before_asylum_application asylum_procedure residence_permit
       toleration_decision deportation_decision).freeze

  enumerize :encounter, in: ENCOUNTERS
  enumerize :exclusive_gender, in: EXCLUSIVE_GENDERS
  enumerize :gender_first_part_of_stamp, in: BENEFICIARY_GENDERS
  enumerize :gender_second_part_of_stamp, in: STAMP_SECOND_PART_GENDERS
  enumerize :treatment_type, in: TREATMENT_TYPES
  enumerize :participant_structure, in: PARTICIPANT_STRUCTURES
  enumerize :residence_status, in: RESIDENCE_STATUSES

  # Friendly ID
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged]

  # Translation
  translate :name, :description, :old_next_steps, :opening_specification

  def slug_candidates
    [
      :name,
      [:name, :location_zip]
    ]
  end

  # Scopes
  scope :approved, -> { where(aasm_state: 'approved') }
  scope :created_at_day, ->(date) { where('created_at::date = ?', date) }
  scope :approved_at_day, ->(date) { where('approved_at::date = ?', date) }
  scope :in_section, lambda { |section|
    joins(:section_filters).where(filters: { identifier: section })
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

  def in_section? section
    section_filters.where(identifier: section).count > 0
  end

  def opening_details?
    !openings.blank? || !opening_specification.blank?
  end

  # def personal?
  #   encounter == 'personal'
  # end
  #
  # def self.per_env_index
  #   if Rails.env.development?
  #     "Offer_development_#{ENV['USER']}"
  #   else
  #     "Offer_#{Rails.env}"
  #   end
  # end
  #
  # def self.personal_index_name locale
  #   "#{per_env_index}_personal_#{locale}"
  # end
  #
  # def self.remote_index_name locale
  #   "#{per_env_index}_remote_#{locale}"
  # end
end
