# Connector model User <-> UserTeam for observing (not contributing to Team)
class UserTeamObservingUser < ActiveRecord::Base
  # Associations
  belongs_to :user, inverse_of: :user_team_observing_users
  belongs_to :user_team, inverse_of: :user_team_observing_users
end
