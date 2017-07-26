module Assignable
  extend ActiveSupport::Concern

  included do
    # Associations
    has_many :assignments, as: :assignable, inverse_of: :assignable,
                           dependent: :destroy

    # the current assignment must be active (open), a root assignment (no
    # parent) and it must belong to the model (and not to a field of the model).
    # There must always be exactly one current_assignment for each assignable.
    has_one :current_assignment,
            ->(assignable) { where(assignable: assignable).active.root.base },
            class_name: 'Assignment', foreign_key: :assignable_id

    # # accepts_nested_attributes_for :assignments
    #
    # # Methods
    # def field_assignments
    #   self.assignments.field
    # end
    #
    # # the current assignment must be active (open), a root assignment (no
    # # parent) and it must belong to the model (and not to a field of the model).
    # # There must always be exactly one current_assignment for each assignable.
    # def current_assignment
    #   self.assignments.active.root.base.first
    # end
    #
    # def current_field_assignment field
    #   # return nil if the required field is not existing on the assignable model
    #   return nil unless self.respond_to?(field)
    #   # return open field assignment if one exists or current model assignment
    #   assignments.active.root.where(assignable_field_type: field).first ||
    #     current_assignment
    # end
    #
    # # closes the current assignment (if one exists) and creates a new one
    # def create_new_assignment! creator_id, creator_team_id, receiver_id, receiver_team_id, message = ''
    #   current_assignment.close! if current_assignment
    #   Assignment.create!(
    #     assignable: self,
    #     assignable_type: self.class.name,
    #     creator_id: creator_id,
    #     creator_team_id: creator_team_id,
    #     receiver_id: receiver_id,
    #     receiver_team_id: receiver_team_id,
    #     message: message
    #   )
    # end
    #
    # # TODO: Sub-Assignments (assignment with parent)
  end
end
