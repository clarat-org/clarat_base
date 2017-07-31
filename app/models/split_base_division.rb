# Connector model
class SplitBaseDivision < ActiveRecord::Base
  belongs_to :split_base, inverse_of: :split_base_divisions
  belongs_to :division, inverse_of: :split_base_divisions
end
