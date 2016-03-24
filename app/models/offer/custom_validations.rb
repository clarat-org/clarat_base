class Offer
  module CustomValidations
    extend ActiveSupport::Concern

    included do
      validate :validate_associated_fields
      validate :only_approved_organizations, if: :approved?
      validate :age_from_fits_age_to
      validate :location_and_area_fit_encounter
      validate :location_fits_organization, on: :update
      validate :contact_people_are_choosable
      validate :section_filters_must_match_categories_section_filters,
               on: :update
      validate :no_more_than_10_next_steps
      # validate :base_offer_id_if_version_greater_5

      private

      # Uses method from CustomValidatable concern.
      def validate_associated_fields
        validate_associated_presence :organizations
        validate_associated_presence :section_filters
        validate_associated_presence :language_filters
        if in_family_section?
          validate_associated_presence :target_audience_filters
        end
      end

      def validate_associated_presence field
        fail_validation field, "needs_#{field}" if send(field).empty?
      end

      def in_family_section?
        section_filters.to_a.any? { |filter| filter.identifier == 'family' }
      end

      ## Custom Validation Methods ##

      # Age From has to be smaller than Age To
      def age_from_fits_age_to
        return if !age_from || !age_to || age_from <= age_to
        errors.add :age_from, I18n.t('offer.validations.age_from_be_smaller')
      end

      # Location is only allowed when encounter is personal, but if it is, it
      # HAS to be present. A remote offer needs an area.
      def location_and_area_fit_encounter
        if personal? && !location
          fail_validation :location, 'needs_location_when_personal'
        elsif !personal?
          fail_validation :location, 'refuses_location_when_remote' if location
          fail_validation :area, 'needs_area_when_remote' unless area
        end
      end

      # Ensure selected organization is the same as the selected location's
      # organization
      def location_fits_organization
        ids = organizations.pluck(:id)
        if personal? && location && !ids.include?(location.organization_id)
          errors.add(
            :location_id,
            I18n.t(
              'offer.validations.location_fits_organization.location_error'
            ))
          errors.add(
            :organizations,
            I18n.t(
              'offer.validations.location_fits_organization.organization_error'
            ))
        end
      end

      # Fail if an organization added to this offer is unapproved
      def only_approved_organizations
        return unless association_instance_get(:organizations) # tests fail w/o
        if organizations.to_a.count { |orga| !orga.approved? } > 0
          approved_organization_names =
            organizations.to_a.select(&:approved?).map(&:name).join(', ')

          fail_validation :organizations, 'only_approved_organizations',
                          list: approved_organization_names
        end
      end

      # Contact people either belong to one of the Organizations or are SPoC
      def contact_people_are_choosable
        contact_people.each do |contact_person|
          next if contact_person.spoc ||
                  organizations.include?(contact_person.organization)
          # There are no intersections between both sets of orgas and not SPoC
          fail_validation :contact_people, 'contact_person_not_choosable'
        end
      end

      # The offers section_filters must match the categories section_filters
      def section_filters_must_match_categories_section_filters
        categories.each do |offer_category|
          next if section_filters.any? do |offer_filter|
            offer_category.section_filters.include?(offer_filter)
          end
          fail_validation(:categories, 'category_for_section_filter_needed',
                          category: offer_category.name)
        end
      end

      def no_more_than_10_next_steps
        return if next_steps.to_a.size <= 10
        fail_validation :next_steps, 'no_more_than_10_next_steps'
      end

      # def base_offer_id_if_version_greater_5
      #   return if !logic_version || logic_version.version < 6 || base_offer_id
      #   fail_validation :base_offer, 'is_needed'
      # end
    end
  end
end
