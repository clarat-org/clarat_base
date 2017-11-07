# Polymorphic join model between organizations/offers and websites.
class Division < ApplicationRecord
  # Concerns
  include Assignable

  # Associations
  belongs_to :organization, inverse_of: :divisions
  has_many :split_base_divisions, inverse_of: :division,
                                  dependent: :destroy
  has_many :split_bases, through: :split_base_divisions,
                         inverse_of: :divisions,
                         source: 'split_base'
  has_many :offer_divisions, inverse_of: :division,
                             dependent: :destroy
  has_many :offers, through: :offer_divisions,
                    inverse_of: :divisions,
                    source: 'offer'
  # has_many :offers, through: :split_bases,
  #                   inverse_of: :divisions

  belongs_to :section, inverse_of: :divisions
  belongs_to :city, inverse_of: :divisions
  belongs_to :area, inverse_of: :divisions

  # delete after deploy
  has_many :divisions_presumed_categories, inverse_of: :division
  has_many :presumed_categories,
           through: :divisions_presumed_categories, source: :category,
           class_name: 'Category', inverse_of: :presuming_divisions

  has_many :divisions_presumed_tags, inverse_of: :division
  has_many :presumed_tags,
           through: :divisions_presumed_tags, source: :tag,
           class_name: 'Tag', inverse_of: :presuming_divisions
  has_many :divisions_presumed_solution_categories, inverse_of: :division
  has_many :presumed_solution_categories,
           through: :divisions_presumed_solution_categories,
           source: :solution_category, class_name: 'SolutionCategory',
           inverse_of: :presuming_divisions

  has_many :hyperlinks, dependent: :destroy, as: :linkable
  has_many :websites, through: :hyperlinks, inverse_of: :divisions

  extend Enumerize
  enumerize :size, in: %w[small medium large]
end
