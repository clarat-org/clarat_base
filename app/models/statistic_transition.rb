class StatisticTransition < ApplicationRecord
  has_many :statistic_chart_transitions, inverse_of: :statistic_transition,
                                         dependent: :destroy
  has_many :statistic_charts, through: :statistic_chart_transitions,
                              inverse_of: :statistic_transitions
end
