# Hierarchical solution categories for offers.
class SolutionCategory < ActiveRecord::Base
  # Closure Tree
  has_closure_tree

  # Associations
  has_many :offers, inverse_of: :solution_category
  has_many :split_bases, inverse_of: :solution_category

  # Validations moved to claradmin

  # Sanitization
  extend Sanitization
  auto_sanitize :name

  # Methods
end
