# HABTM Connector Table for StatisticCharts <-> StatisticTransitions
class DivisionsPresumedSolutionCategory < ActiveRecord::Base
  belongs_to :division, inverse_of: :divisions_presumed_solution_categories
  belongs_to :solution_category,
             inverse_of: :divisions_presumed_solution_categories
end
