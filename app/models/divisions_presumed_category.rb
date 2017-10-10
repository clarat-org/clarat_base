# HABTM Connector Table for StatisticCharts <-> StatisticTransitions
class DivisionsPresumedCategory < ApplicationRecord
  belongs_to :division, inverse_of: :divisions_presumed_categories
  belongs_to :tag, inverse_of: :divisions_presumed_categories
end
