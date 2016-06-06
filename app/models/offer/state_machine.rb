class Offer
  module StateMachine
    extend ActiveSupport::Concern

    included do
      include AASM
      aasm do
        ## States

        # Normal Workflow
        state :initialized, initial: true
        state :completed
        state :approved

        # Special states object might enter before it is approved
        state :dozing # For uncompleted offers that we want to track
        state :under_construction_pre # Website under construction pre approve

        # Special states object might enter after it was approved
        state :paused # I.e. Seasonal offer is in off-season
        state :expired # Happens automatically after a pre-set amount of time
        state :internal_feedback # There was an issue (internal)
        state :external_feedback # There was an issue (external)
        state :organization_deactivated # An associated orga was deactivated
        state :under_construction_post # Website under construction post approve

        ## Transitions

        event :reinitialize do
          transitions from: :dozing, to: :initialized
          transitions from: :under_construction_pre, to: :initialized
        end

        event :complete, before: :set_completed_information,
                         success: :generate_translations! do
          transitions from: :initialized, to: :completed
        end

        event :approve, before: :set_approved_information do
          # TODO: reactivate guard!!!
          transitions from: :completed, to: :approved # , guard: :different_actor?
          transitions from: :paused, to: :approved
          transitions from: :expired, to: :approved
          transitions from: :internal_feedback, to: :approved
          transitions from: :external_feedback, to: :approved
          transitions from: :organization_deactivated, to: :approved,
                      guard: :all_organizations_approved?
          transitions from: :under_construction_post, to: :approved
        end

        event :pause do
          transitions from: :approved, to: :paused
          transitions from: :expired, to: :paused
          transitions from: :internal_feedback, to: :paused
          transitions from: :external_feedback, to: :paused
        end

        event :expire do
          transitions from: :approved, to: :expired
          transitions from: :paused, to: :expired
          transitions from: :internal_feedback, to: :expired
          transitions from: :external_feedback, to: :expired
        end

        event :deactivate_internal do
          transitions from: :approved, to: :internal_feedback
          transitions from: :paused, to: :internal_feedback
          transitions from: :expired, to: :internal_feedback
          transitions from: :external_feedback, to: :internal_feedback
        end

        event :deactivate_external do
          transitions from: :approved, to: :external_feedback
          transitions from: :paused, to: :external_feedback
          transitions from: :expired, to: :external_feedback
          transitions from: :internal_feedback, to: :external_feedback
        end

        event :deactivate_through_organization do
          transitions from: :approved, to: :organization_deactivated,
                      guard: :at_least_one_organization_not_approved?
        end

        event :doze do
          transitions from: :initialized, to: :dozing
        end

        event :website_under_construction do
          # pre approve
          transitions from: :initialized, to: :under_construction_pre
          transitions from: :completed, to: :under_construction_pre
          # post approve
          transitions from: :approved, to: :under_construction_post
          transitions from: :paused, to: :under_construction_post
          transitions from: :expired, to: :under_construction_post
          # TODO: this is tricky
          transitions from: :internal_feedback, to: :under_construction_post
          transitions from: :external_feedback, to: :under_construction_post
          transitions from: :organization_deactivated, to: :under_construction_post
        end
      end

      private

      def at_least_one_organization_not_approved?
        organizations.where.not(aasm_state: 'approved').any?
      end

      def all_organizations_approved?
        !at_least_one_organization_not_approved?
      end

      def set_approved_information
        self.approved_at = Time.zone.now
        self.approved_by = current_actor
        # update to current LogicVersion
        self.logic_version_id = LogicVersion.last.id
      end

      def set_completed_information
        # update to current LogicVersion
        self.logic_version_id = LogicVersion.last.id
      end

      def different_actor?
        created_by && current_actor && created_by != current_actor
      end
    end
  end
end
