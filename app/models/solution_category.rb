# Hierarchical solution categories for offers.
class SolutionCategory < ApplicationRecord
  # Closure Tree
  has_closure_tree

  # Associations
  has_many :offers, inverse_of: :solution_category
  has_many :split_bases, inverse_of: :solution_category

  has_many :divisions_presumed_solution_categories,
           inverse_of: :solution_category
  has_many :presuming_divisions,
           through: :divisions_presumed_solution_categories,
           source: :division, inverse_of: :presumed_solution_categories

  # Sanitization
  extend Sanitization
  auto_sanitize :name

  # Methods
end
