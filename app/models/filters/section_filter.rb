class SectionFilter < Filter
  # Associtations
  has_many :target_audience_filters
  has_many :divisions, inverse_of: :section_filter

  IDENTIFIER = %w(family refugees).freeze
  enumerize :identifier, in: SectionFilter::IDENTIFIER
end
