class UserTeam < ActiveRecord::Base
  # Concerns
  include Trackable

  # Associations
  has_many :user_team_users, inverse_of: :user_team
  has_many :users, through: :user_team_users, inverse_of: :user_teams
  belongs_to :lead, class_name: 'User', inverse_of: :led_teams

  belongs_to :parent, class_name: 'UserTeam', inverse_of: :children
  has_many :children, class_name: 'UserTeam', foreign_key: 'parent_id', inverse_of: :parent

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
