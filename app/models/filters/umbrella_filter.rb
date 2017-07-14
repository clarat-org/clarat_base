# Multiple umbrella selection
class UmbrellaFilter < Filter
  # Associations
  has_many :offers, through: :filters_offers

  IDENTIFIER = %w(caritas diakonie awo dpw drk asb zwst dbs vdw bags svdkd bkd
                  church hospital public other_or_none).freeze
  enumerize :identifier, in: UmbrellaFilter::IDENTIFIER
end
