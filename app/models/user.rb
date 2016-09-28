# Devise user model, only used for researchers and supervisors to access the
# backend. Not for clients yet.
class User < ActiveRecord::Base
  # Associations
  has_many :authored_notes, class_name: 'Note', inverse_of: :user
  has_many :user_team_users, inverse_of: :user
  has_many :user_teams, through: :user_team_users, inverse_of: :users
  belongs_to :current_team, class_name: 'UserTeam', inverse_of: :current_users
  has_many :statistics, inverse_of: :user
  has_many :absences, inverse_of: :user
  has_many :time_allocations, inverse_of: :user

  # Validations
  # validates :email, uniqueness: true, presence: true

  # Enumerization
  extend Enumerize
  enumerize :role, in: %w(standard researcher super)

  # Scopes
  scope :researcher, -> { where(role: 'researcher') }
end
