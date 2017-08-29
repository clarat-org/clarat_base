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
end
