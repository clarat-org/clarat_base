class ProductivityGoal < ActiveRecord::Base
  # Associations
  belongs_to :user_team, inverse_of: :productivity_goals
end
