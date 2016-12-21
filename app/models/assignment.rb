# Basic Assignment Model. Can be connected to any other model via Assignable
# module. Connects the Model with a user and/or a team. Only used in Backend.
class Assignment < ActiveRecord::Base
  include AASM
  # Concerns

  # Associations
  belongs_to :assignable, polymorphic: true

  # Creator
  belongs_to :creator, class_name: 'User', inverse_of: :created_assignments
  belongs_to :creator_team, class_name: 'UserTeam', inverse_of: :created_assignments
  # Reciever
  belongs_to :reciever, class_name: 'User', inverse_of: :recieved_assignments
  belongs_to :reciever_team, class_name: 'UserTeam', inverse_of: :recieved_assignments

  belongs_to :parent, class_name: 'Assignment', inverse_of: :children
  has_many :children, class_name: 'Assignment', inverse_of: :parent

  # Scopes
  scope :active, -> { where(aasm_state: 'open') }
  scope :closed, -> { where(aasm_state: 'closed') }
  scope :base, -> { where(assignable_field_type: '') }
  scope :field, -> { where.not(assignable_field_type: '') }
  scope :root, -> { where(parent_id: nil) } # Root Assignments have no parent

  # Enumerization
  # extend Enumerize
  # enumerize :topic, in: %w(internal_info external_info)

  # Validations
  # validates :text, presence: true, length: { maximum: 800 }
  # validates :topic, presence: true
  # validates :notable, presence: true
  # validates :user, presence: true

  # State Machine
  aasm do
    state :open, initial: true # Assignment was created and is open
    # state :pending_children # TODO: needed ???
    state :closed # Assignment is finished and only used for history/versioning

    event :close do
      transitions from: :open, to: :closed # , success: :close_children_and_create_system_assignment
    end

    event :re_open do # , guard: :no_other_open_assignment? do
      transitions from: :closed, to: :open
    end
  end

  # Methods
  # delegate :name, to: :creator, prefix: true
  # delegate :name, to: :creator_team, prefix: true
  # delegate :name, to: :reciever, prefix: true
  # delegate :name, to: :reciever_team, prefix: true

  # def close_and_assign_system!
  #   # TODO
  #   true
  # end

  # private

  # def no_other_open_assignment?
  #   # TODO
  #   true
  # end

  # def close_children_and_create_system_assignment
  #   # TODO
  #   true
  # end
end
