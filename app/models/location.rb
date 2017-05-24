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
  validates :name, length: { maximum: 100 }
  validates :street, presence: true,
                     format: /\A.+\d*.*\z/ # optional digit for house number
  validates :addition, length: { maximum: 255 }
  validates :zip, presence: true, length: { is: 5 },
                  if: -> (location) { location.in_germany }
  validates :display_name, presence: true

  validates :city_id, presence: true
  validates :organization_id, presence: true
  validates :federal_state_id, presence: true,
                               if: -> (location) { location.in_germany }

  # Scopes
  scope :hq, -> { where(hq: true).limit(1) }

  # Geocoding
  # geocoded_by :full_address

  # Methods

  delegate :name, to: :federal_state, prefix: true
  delegate :name, to: :city, prefix: true, allow_nil: true
  delegate :name, to: :organization, prefix: true, allow_nil: true

  before_validation :generate_display_name
  def generate_display_name
    display = organization_name.to_s
    display += ", #{name}" unless name.blank?
    display += " | #{street}"
    display += ", #{addition}," unless addition.blank?
    self.display_name = display + " #{zip} #{city_name}"
  end

  def address
    "#{street}, #{zip} #{city_name}"
  end

  private

  def full_address
    "#{address} #{federal_state_name}"
  end
end
