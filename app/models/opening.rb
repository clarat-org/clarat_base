# Opening Times of Offers
class Opening < ActiveRecord::Base
  # Associations
  has_and_belongs_to_many :offers

  # Enumerization
  extend Enumerize
  DAYS = %w(mon tue wed thu fri sat sun).freeze
  enumerize :day, in: DAYS

  # Validations moved to claradmin
end
