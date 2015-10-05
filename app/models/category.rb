# Hierarchical categorier to sort offers.
class Category < ActiveRecord::Base
  # AwesomeNestedSet
  # acts_as_nested_set counter_cache: :children_count, depth_column: :depth
  has_closure_tree

  # Concerns
  include CustomValidatable

  # associtations
  has_and_belongs_to_many :offers
  has_and_belongs_to_many :section_filters,
                          association_foreign_key: 'filter_id'
  has_many :organizations, through: :offers
  # To order with closure_tree
  has_closure_tree order: 'sort_order'

  # Validations
  validates :name, uniqueness: true, presence: true

  # Custom Validations
  validate :validate_section_filter_presence

  # Sanitization
  extend Sanitization
  auto_sanitize :name

  # Scope
  scope :mains, -> { where.not(icon: nil).order(:icon).limit(5) }

  # Methods

  # alias for rails_admin_nestable
  singleton_class.send :alias_method, :arrange, :hash_tree

  # cached hash_tree, prepared for use in offers#index
  def self.sorted_hash_tree
    Rails.cache.fetch 'sorted_hash_tree' do
      hash_tree.sort_by { |tree| tree.first.icon || '' }
    end
  end

  # display name: main categories get an asterisk
  def name_with_optional_asterisk
    name + (icon ? '*' : '') if name
  end

  # custom validation method
  def validate_section_filter_presence
    fail_validation(:section_filters, 'needs_section_filters') if
      send(:section_filters).empty?
  end
end
