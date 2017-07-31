# One of the main models: A location that an organization uses to provide a
# local offer. Has geocoordinates to make associated offers locally searchable.
class Location < ActiveRecord::Base
  has_paper_trail

  # Associations
  belongs_to :organization, inverse_of: :locations, counter_cache: true
  belongs_to :federal_state, inverse_of: :locations
  belongs_to :city, inverse_of: :locations
  has_many :offers, inverse_of: :location

  # Validations

  # Scopes
  scope :hq, -> { where(hq: true).limit(1) }

  # Geocoding
  geocoded_by :full_address

  # Methods

  delegate :name, to: :federal_state, prefix: true
  delegate :name, to: :city, prefix: true, allow_nil: true
  delegate :name, to: :organization, prefix: true, allow_nil: true

  def address
    "#{street}, #{zip} #{city_name}"
  end

  private

  def full_address
    "#{address} #{federal_state_name}"
  end
end
