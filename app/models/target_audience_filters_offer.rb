# Connector Model Offer <-> Filter
class TargetAudienceFiltersOffer < ActiveRecord::Base
  # Associations
  belongs_to :target_audience_filter, inverse_of: :target_audience_filters_offers
  belongs_to :offer, inverse_of: :target_audience_filters_offers

  # Constants
  MIN_AGE = 0
  MAX_AGE = 99
  STAMP_FIRST_PART_GENDERS = %w(female male).freeze
  STAMP_SECOND_PART_GENDERS = %w(female male neutral).freeze
  # ^ nil means inclusive to any gender
  RESIDENCY_STATUSES =
    %w(before_the_asylum_decision with_a_residence_permit
       with_temporary_suspension_of_deportation
       with_deportation_decision).freeze
end
