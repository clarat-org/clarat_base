# The end point that can be contacted by a visitor to get Information about an
# offer.
class ContactPerson < ApplicationRecord
  # Concerns
  include Translation

  # Associations
  belongs_to :organization, inverse_of: :contact_people
  belongs_to :email, inverse_of: :contact_people

  has_many :contact_person_offers, inverse_of: :contact_person,
                                   dependent: :destroy
  has_many :offers, through: :contact_person_offers, inverse_of: :contact_people

  # Enumerization
  extend Enumerize
  enumerize :gender, in: %w[female male]
  enumerize :academic_title, in: %w[dr prof_dr]
  enumerize :position, in: %w[superior public_relations other]

  # Translation
  translate :responsibility

  # Validations

  # Methods
  delegate :name, to: :organization, prefix: true, allow_nil: true
  delegate :address, :address?, to: :email, prefix: true, allow_nil: true

  # concatenated area code and telephone number
  %w[1 2].each do |n|
    define_method "telephone_#{n}".to_sym do
      self["area_code_#{n}"].to_s + self["local_number_#{n}"]
    end
  end

  def fax
    fax_area_code.to_s + fax_number
  end
end
