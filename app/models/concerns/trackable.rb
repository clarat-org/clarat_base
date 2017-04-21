module Trackable
  extend ActiveSupport::Concern

  included do
    # Associations
    has_many :statistics, as: :trackable, inverse_of: :trackable,
                          dependent: :destroy
  end
end
