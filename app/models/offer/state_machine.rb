class Offer
  # This module represents the entire offer state machine and should stay
  # together
  # rubocop:disable Metrics/ModuleLength
  module StateMachine
    extend ActiveSupport::Concern

    included do
      include AASM
      aasm do
        ## States

        # Normal Workflow
        state :initialized, initial: true
        state :completed
        state :approval_process # indicates the beginning of the approval process
        state :approved
        state :checkup_process # indicates the beginning of the checkup_process (after deactivation)

        # Special states object might enter before it is approved
        state :dozing # For uncompleted offers that we want to track
        state :under_construction_pre # Website under construction pre approve

        # Special states object might enter after it was approved
        state :paused # I.e. Seasonal offer is in off-season (set automatically)
        state :expired # Happens automatically after a pre-set amount of time
        state :internal_feedback # There was an issue (internal)
        state :external_feedback # There was an issue (external)
        state :organization_deactivated # An associated orga was deactivated
        state :under_construction_post # Website under construction post approve
        state :seasonal_pending # seasonal offer is reviewed but out of TimeFrame
        state :website_unreachable # crawler could not reach website twice in a row

        ## Transitions

        event :reinitialize do
          transitions from: :dozing, to: :initialized
          transitions from: :under_construction_pre, to: :initialized
        end

        event :doze do
          transitions from: :initialized, to: :dozing
          transitions from: :checkup_process, to: :dozing
        end

        event :complete, before: :set_completed_information do
          transitions from: :initialized, to: :completed
          transitions from: :checkup_process, to: :completed
        end

        event :start_approval_process do
          # TODO: reactivate guard!!!
          transitions from: :completed, to: :approval_process # , guard: :different_actor?
        end

        event :approve, before: :set_approved_information,
                        success: :generate_translations! do
          transitions from: :approval_process, to: :seasonal_pending,
                      guard: :seasonal_offer_not_yet_to_be_approved?
          transitions from: :checkup_process, to: :seasonal_pending,
                      guard: :seasonal_offer_not_yet_to_be_approved?
          # TODO: reactivate guard!!!
          transitions from: :approval_process, to: :approved # , guard: :different_actor?
          transitions from: :checkup_process, to: :approved # , guard: :different_actor?
          transitions from: :organization_deactivated, to: :approved
        end

        event :expire do
          transitions from: :approved, to: :expired
        end

        event :deactivate_internal do
          transitions from: :approved, to: :internal_feedback
          transitions from: :expired, to: :internal_feedback
          transitions from: :external_feedback, to: :internal_feedback
          transitions from: :under_construction_post, to: :internal_feedback
        end

        event :deactivate_external do
          transitions from: :approved, to: :external_feedback
          transitions from: :expired, to: :external_feedback
          transitions from: :internal_feedback, to: :external_feedback
          transitions from: :under_construction_post, to: :external_feedback
        end

        event :deactivate_through_organization do
          transitions from: :approved, to: :organization_deactivated,
                      guard: :at_least_one_organization_not_visible?
          transitions from: :expired, to: :organization_deactivated,
                      guard: :at_least_one_organization_not_visible?
        end

        event :website_under_construction do
          # pre approve
          transitions from: :initialized, to: :under_construction_pre
          transitions from: :completed, to: :under_construction_pre
          # post approve
          transitions from: :approved, to: :under_construction_post
          transitions from: :expired, to: :under_construction_post
          transitions from: :internal_feedback, to: :under_construction_post
          transitions from: :external_feedback, to: :under_construction_post
          transitions from: :organization_deactivated, to: :under_construction_post
          transitions from: :checkup_process, to: :under_construction_post
        end

        event :start_checkup_process do
          transitions from: :approved, to: :checkup_process
          transitions from: :paused, to: :checkup_process
          transitions from: :expired, to: :checkup_process
          transitions from: :internal_feedback, to: :checkup_process
          transitions from: :external_feedback, to: :checkup_process
          transitions from: :under_construction_post, to: :checkup_process
          transitions from: :website_unreachable, to: :checkup_process
          transitions from: :organization_deactivated, to: :checkup_process
        end

        event :return_to_editing do
          transitions from: :completed, to: :checkup_process,
                      guard: :was_approved?
          transitions from: :completed, to: :initialized
        end
      end

      private

      def at_least_one_organization_not_visible?
        organizations.where.not(aasm_state: %w(approved all_done)).any?
      end

      def set_approved_information
        self.approved_at = Time.zone.now
        self.approved_by = current_actor
        # update to current LogicVersion
        self.logic_version_id = LogicVersion.last.id
      end

      def set_completed_information
        self.completed_at = Time.zone.now
        self.completed_by = current_actor
        # update to current LogicVersion
        self.logic_version_id = LogicVersion.last.id
      end

      def different_actor?
        created_by && current_actor && created_by != current_actor
      end

      def seasonal_offer_not_yet_to_be_approved?
        !starts_at.nil? && starts_at > Time.zone.now # && different_actor?
      end

      # indicates that the offer was already approved once. Required in order to
      # filter re-write offers
      def was_approved?
        !self.approved_by.nil? && !self.approved_at.nil?
      end
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
