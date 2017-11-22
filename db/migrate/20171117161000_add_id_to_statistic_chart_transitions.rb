class AddIdToStatisticChartTransitions < ActiveRecord::Migration[5.1]
  def change
    add_column :statistic_chart_transitions, :id, :primary_key
  end
end
