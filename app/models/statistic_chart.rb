class StatisticChart < ActiveRecord::Base
  belongs_to :user_team, inverse_of: :statistic_charts
  belongs_to :user, inverse_of: :statistic_charts

  has_many :statistic_chart_transitions, inverse_of: :statistic_chart
  has_many :statistic_transitions, through: :statistic_chart_transitions,
                                   inverse_of: :statistic_charts

  has_many :statistic_chart_goals, inverse_of: :statistic_chart
  has_many :statistic_goals, through: :statistic_chart_goals,
                             inverse_of: :statistic_charts
end
