# Hierarchical problem categories to sort offers.
class Category < ActiveRecord::Base
  # Closure Tree
  has_closure_tree order: 'sort_order'

  # Concerns
  include CustomValidatable

  # Associations
  has_many :categories_sections
  has_many :sections, through: :categories_sections
  has_many :categories_offers
  has_many :offers, through: :categories_offers
  has_many :organizations, through: :offers

  # Validations
  validates :name_de, presence: true
  validates :name_en, presence: true

  # Custom Validations
  validate :validate_section_presence
  validate :validate_sections_with_parent

  # Sanitization
  extend Sanitization
  auto_sanitize :name_de

  # Scope
  scope :mains, -> { where.not(icon: nil).order(:icon).limit(7) }
  scope :in_section, lambda { |section|
    joins(:sections).where('sections.identifier = ?', section)
  }

  # Methods

  # locale-specific name getter with two fallbacks
  def name(locale = I18n.locale)
    output = send(:"name_#{locale}")
    output = output.blank? ? name_en : output
    output.blank? ? name_de : output
  end

  def keywords(locale = I18n.locale)
    self.try("keywords_#{locale}") || ''
  end

  # custom validation methods
  def validate_section_presence
    return unless send(:sections).empty?
    fail_validation(:sections, 'needs_sections')
  end

  def validate_sections_with_parent
    if parent_id
      sections.each do |filter|
        parent = Category.find(parent_id)
        next if parent.sections.pluck(:id).include? filter.id
        fail_validation(:sections,
                        'parent_needs_same_section',
                        parent_name: parent.name,
                        filter_name: filter.name)
      end
    end
  end
end
