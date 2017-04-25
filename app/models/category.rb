# Hierarchical problem categories to sort offers.
class Category < ActiveRecord::Base
  # Closure Tree
  has_closure_tree order: 'sort_order'

  # Concerns
  include CustomValidatable

  # Associations
  has_and_belongs_to_many :section_filters,
                          association_foreign_key: 'filter_id'
  has_many :categories_offers
  has_many :offers, through: :categories_offers
  has_many :organizations, through: :offers

  # Validations
  validates :name_de, presence: true
  validates :name_en, presence: true

  # Custom Validations
  validate :validate_section_filter_presence
  validate :validate_section_filters_with_parent

  # Sanitization
  extend Sanitization
  auto_sanitize :name_de

  # Scope
  scope :mains, -> { where.not(icon: nil).order(:icon).limit(7) }
  scope :in_section, lambda { |section|
    joins(:section_filters).where(filters: { identifier: section })
  }

  # Methods

  # locale-specific name getter with two fallbacks
  def name(locale = I18n.locale)
    output = send(:"name_#{locale}")
    output = output.blank? ? name_en : output
    output.blank? ? name_de : output
  end

  # custom validation methods
  def validate_section_filter_presence
    return unless send(:section_filters).empty?
    fail_validation(:section_filters, 'needs_section_filters')
  end

  def validate_section_filters_with_parent
    if parent_id
      section_filters.each do |filter|
        parent = Category.find(parent_id)
        next if parent.section_filters.pluck(:id).include? filter.id
        fail_validation(:section_filters,
                        'parent_needs_same_section_filter',
                        parent_name: parent.name,
                        filter_name: filter.name)
      end
    end
  end
end
