class UserTeam < ActiveRecord::Base
  # Associations
  has_many :user_team_users, inverse_of: :user_team
  has_many :users, through: :user_team_users, inverse_of: :user_teams
  has_many :current_users, class_name: 'User', foreign_key: 'current_team_id',
                           inverse_of: :current_team

  has_many :statistic_charts, inverse_of: :user_team
  has_many :statistics, inverse_of: :user_team

  has_many :created_assignments, class_name: 'Assignment',
                                 foreign_key: 'creator_team_id',
                                 inverse_of: :creator_team
  has_many :received_assignments, class_name: 'Assignment',
                                  foreign_key: 'receiver_team_id',
                                  inverse_of: :receiver_team

  # Enumerization
  extend Enumerize
  CLASSIFICATIONS = %w(researcher translator).freeze
  enumerize :classification, in: CLASSIFICATIONS

  # Scopes
  CLASSIFICATIONS.each do |c_name|
    scope c_name, -> { where(classification: c_name) }
  end
end
