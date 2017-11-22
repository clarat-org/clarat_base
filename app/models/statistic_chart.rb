class StatisticChart < ApplicationRecord
  # belongs_to :user_team, inverse_of: :statistic_charts # NOTE for later use?
  belongs_to :user, inverse_of: :statistic_charts

  has_many :statistic_chart_transitions, inverse_of: :statistic_chart,
                                         dependent: :destroy
  has_many :statistic_transitions, through: :statistic_chart_transitions,
                                   inverse_of: :statistic_charts

  has_many :statistic_chart_goals, inverse_of: :statistic_chart,
                                   dependent: :destroy
  has_many :statistic_goals, through: :statistic_chart_goals,
                             inverse_of: :statistic_charts

  # Enumerization
  extend Enumerize
  TITLES = %w[completion approval].freeze

  enumerize :title, in: TITLES
end
