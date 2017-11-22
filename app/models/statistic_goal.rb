class StatisticGoal < ApplicationRecord
  has_many :statistic_chart_goals, inverse_of: :statistic_goal,
                                   dependent: :destroy
  has_many :statistic_charts, through: :statistic_chart_goals,
                              inverse_of: :statistic_goals
end
