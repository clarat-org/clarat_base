# HABTM Connector Table for StatisticCharts <-> StatisticTransitions
class StatisticChartTransition < ApplicationRecord
  belongs_to :statistic_chart, inverse_of: :statistic_chart_transitions
  belongs_to :statistic_transition, inverse_of: :statistic_chart_transitions
end
