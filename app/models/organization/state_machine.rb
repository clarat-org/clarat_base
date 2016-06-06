class Organization
  module StateMachine
    extend ActiveSupport::Concern

    included do
      include AASM
      aasm do
        ## States

        state :initialized, initial: true
        state :completed
        state :approved

        # Special states object might enter before it is approved
        state :under_construction_pre, # Website under construction pre approve
              after_enter: :deactivate_offers_to_under_construction!,
              after_exit: :reactivate_offers_from_under_construction!

        # Special states object might enter after it was approved
        state :internal_feedback, # There was an issue (internal)
              after_enter: :deactivate_offers!,
              after_exit: :reactivate_offers!
        state :external_feedback, # There was an issue (external)
              after_enter: :deactivate_offers!,
              after_exit: :reactivate_offers!
        state :under_construction_post, # Website under construction post approve
              after_enter: :deactivate_offers_to_under_construction!,
              after_exit: :reactivate_offers_from_under_construction!

        ## Transitions

        event :reinitialize do
          transitions from: :under_construction_pre, to: :initialized
        end

        event :complete do
          transitions from: :initialized, to: :completed
        end

        event :approve, before: :set_approved_information do
          # TODO: reactivate guard!!!
          transitions from: :completed, to: :approved # , guard: :different_actor?
          transitions from: :internal_feedback, to: :approved
          transitions from: :external_feedback, to: :approved
          transitions from: :under_construction_post, to: :approved
        end

        event :deactivate_internal do
          transitions from: :approved, to: :internal_feedback
          transitions from: :external_feedback, to: :internal_feedback
        end

        event :deactivate_external do
          transitions from: :approved, to: :external_feedback
          transitions from: :internal_feedback, to: :external_feedback
        end

        event :website_under_construction do
          # pre approve
          transitions from: :initialized, to: :under_construction_pre
          transitions from: :completed, to: :under_construction_pre
          # post approve
          transitions from: :approved, to: :under_construction_post
          transitions from: :internal_feedback, to: :under_construction_post
          transitions from: :external_feedback, to: :under_construction_post
        end
      end

      # When an organization switches from approved to an unapproved state,
      # also deactivate all it's associated approved offers
      def deactivate_offers!
        offers.approved.find_each do |offer|
          next if offer.deactivate_through_organization!
          raise "#deactivate_offers! failed for #{offer.id}"
        end
      end

      # When an organization switches from an unapproved state to approved,
      # also reactivate all it's associated organization_deactivated offers
      # (if possible)
      def reactivate_offers!
        offers.where(aasm_state: 'organization_deactivated').find_each do |o|
          o.approve! if o.may_approve?
        end
      end

      # When an organization switches to a website_under_construction state, the
      # associated offers (in states: initialized, completed, approved or
      # organization_deactivated) also transitions to under_construction
      def deactivate_offers_to_under_construction!
        allowed_states = %w(initialized completed approved
                            organization_deactivated)
        offers.select { |o| allowed_states.include? o.aasm_state }.each do |offer|
          next if offer.website_under_construction!
          raise "#deactivate_offer_to_under_construction failed for #{offer.id}"
        end
      end

      # When an organization switches from an under_construction state to
      # approved, also reactivate all it's associated under_construction offers
      # (if possible)
      def reactivate_offers_from_under_construction!
        # pre-approve offers => re-initialize
        offers.where(aasm_state: 'under_construction_pre')
              .find_each(&:reinitialize!)
        # post-approved offers => approve (if possible)
        offers.where(aasm_state: 'under_construction_post').find_each do |o|
          o.approve! if o.may_approve?
        end
      end
    end
  end
end
