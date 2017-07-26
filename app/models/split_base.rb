class SplitBase < ActiveRecord::Base
  # Associations
  has_many :offers, inverse_of: :split_base
  has_many :split_base_divisions, inverse_of: :split_base,
                                  dependent: :destroy
  has_many :divisions, through: :split_base_divisions,
                       inverse_of: :split_bases,
                       source: 'division'
  has_many :organizations, through: :divisions,
                           inverse_of: :split_bases

  belongs_to :solution_category, inverse_of: :split_bases

  # Validations
  UNIQUE_FIELDSET =
    [:title, :clarat_addition, :solution_category_id].freeze

  validates :title, presence: true, uniqueness: {
    scope: UNIQUE_FIELDSET - [:title]
  }
  validates :clarat_addition, uniqueness: {
    scope: UNIQUE_FIELDSET - [:clarat_addition]
  }
  # validates :organization_id, presence: true, uniqueness: {
  #   scope: UNIQUE_FIELDSET - [:organization_id]
  # }
  validates :solution_category_id, presence: true, uniqueness: {
    scope: UNIQUE_FIELDSET - [:solution_category_id]
  }
end
