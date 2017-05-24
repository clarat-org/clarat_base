# Additional traits
class TraitFilter < Filter
  # Associations
  has_many :offers, through: :filters_offers

  IDENTIFIER = %w(anonymous free confidential day_and_night charged
                  accessibility).freeze
  enumerize :identifier, in: TraitFilter::IDENTIFIER
end
