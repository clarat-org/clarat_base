# HABTM Connector Table for StatisticCharts <-> StatisticGoals
class StatisticChartGoal < ActiveRecord::Base
  belongs_to :statistic_chart, inverse_of: :statistic_chart_goals
  belongs_to :statistic_goal, inverse_of: :statistic_chart_goals
end
