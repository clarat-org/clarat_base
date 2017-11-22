class AddIdToStatisticChartGoals < ActiveRecord::Migration[5.1]
  def change
    add_column :statistic_chart_goals, :id, :primary_key
  end
end
