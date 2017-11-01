# HABTM Connector Table for StatisticCharts <-> StatisticTransitions
class DivisionsPresumedTag < ApplicationRecord
  belongs_to :division, inverse_of: :divisions_presumed_tags
  belongs_to :tag, inverse_of: :divisions_presumed_tags
end
