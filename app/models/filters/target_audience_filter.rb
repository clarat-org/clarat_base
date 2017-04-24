class TargetAudienceFilter < Filter
  # Associations
  # should always remain a single reference (no habtm or hmt)!!
  belongs_to :section

  FAMILY_IDENTIFIER = %w(family_children family_parents family_nuclear_family
                         family_relatives family_parents_to_be
                         family_everyone).freeze

  REFUGEES_IDENTIFIER = %w(refugees_children refugees_umf refugees_parents
                           refugees_families refugees_parents_to_be
                           refugees_general).freeze

  IDENTIFIER = FAMILY_IDENTIFIER + REFUGEES_IDENTIFIER

  enumerize :identifier, in: TargetAudienceFilter::IDENTIFIER
end
