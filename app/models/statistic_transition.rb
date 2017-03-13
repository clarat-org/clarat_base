class StatisticTransition < ActiveRecord::Base
  has_many :statistic_chart_transitions, inverse_of: :statistic_transition
  has_many :statistic_charts, through: :statistic_chart_transitions,
                              inverse_of: :statistic_transitions
end
