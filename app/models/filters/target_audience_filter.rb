class TargetAudienceFilter < Filter
  # Associtations
  belongs_to :section_filter

  IDENTIFIER = %w(children parents nuclear_family acquaintances pregnant_woman
                  everyone refugees refugees_children refugees_adolescents
                  refugees refugees_children_and_adolescents refugees_umf
                  refugees_ujf refugees_families refugees_pre_asylum_procedure
                  refugees_asylum_procedure refugees_deportation_decision
                  refugees_toleration_decision refugees_residence_permit)
  enumerize :identifier, in: TargetAudienceFilter::IDENTIFIER
end
