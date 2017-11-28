# Devise user model, only used for researchers and supervisors to access the
# backend. Not for clients yet.
class User < ApplicationRecord
  # Concerns
  include Trackable

  # Associations
  has_many :user_team_users, inverse_of: :user, dependent: :destroy
  has_many :user_teams, through: :user_team_users, inverse_of: :users
  has_many :led_teams, class_name: 'UserTeam',
                       foreign_key: 'lead_id',
                       inverse_of: :lead

  has_many :user_team_observing_users, inverse_of: :user, dependent: :destroy
  has_many :observed_user_teams, through: :user_team_observing_users,
                                 class_name: 'UserTeam',
                                 source: :user_team,
                                 inverse_of: :observing_users
  # has_many :statistics, inverse_of: :user
  has_many :statistic_charts, inverse_of: :user, dependent: :destroy

  has_many :absences, inverse_of: :user
  has_many :time_allocations, inverse_of: :user

  has_many :created_assignments, class_name: 'Assignment',
                                 foreign_key: 'creator_id',
                                 inverse_of: :creator, dependent: :nullify
  has_many :received_assignments, class_name: 'Assignment',
                                  foreign_key: 'receiver_id',
                                  inverse_of: :receiver, dependent: :nullify

  # Validations
  # validates :email, uniqueness: true, presence: true

  # Enumerization
  extend Enumerize
  enumerize :role, in: %w[standard researcher super]

  # Scopes
  scope :researcher, -> { where(role: 'researcher') }
end
