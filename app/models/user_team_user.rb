# Connector model User <-> UserTeam
class UserTeamUser < ActiveRecord::Base
  # Associations
  belongs_to :user, inverse_of: :user_team_users
  belongs_to :user_team, inverse_of: :user_team_users
end
