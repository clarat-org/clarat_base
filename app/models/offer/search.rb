class Offer
  # This module provides a lot of search configurations that should stay
  # together:
  # rubocop:disable Metrics/ModuleLength
  module Search
    extend ActiveSupport::Concern

    included do
      include AlgoliaSearch

      def self.per_env_index
        if Rails.env.development?
          "Offer_development_#{ENV['USER']}"
        else
          "Offer_#{Rails.env}"
        end
      end

      def self.personal_index_name locale
        "#{per_env_index}_personal_#{locale}"
      end

      def self.remote_index_name locale
        "#{per_env_index}_remote_#{locale}"
      end

      algoliasearch do
        I18n.available_locales.each do |locale|
          index = %w(
            name description code_word next_steps keyword_string
            organization_names category_names
          )
          # :category_string,
          attributes = [:organization_count, :location_address, :slug,
                        :encounter, :keyword_string, :organization_names,
                        :location_visible, :code_word]
          facets = [:_age_filters, :_language_filters,
                    :_section_filters, :_target_audience_filters,
                    :_exclusive_gender_filters]

          add_index Offer.personal_index_name(locale),
                    disable_indexing: Rails.env.test?,
                    if: :personal_indexable? do
            attributesToIndex index
            ranking %w(typo geo words proximity attribute exact custom)
            attribute(:name) { send("name_#{locale}") }
            attribute(:description) { send("description_#{locale}") }
            attribute(:next_steps)  { _next_steps locale }
            attribute(:lang) { lang(locale) }
            attribute(:_tags) { _tags(locale) }
            attribute(:_stamp_family) { _stamp_family(locale) }
            attribute(:_stamp_refugees) { _stamp_refugees(locale) }
            attribute(:category_names)  { category_names(locale) }
            add_attribute(*attributes)
            add_attribute(*facets)
            add_attribute :_geoloc
            attributesForFaceting facets + [:_tags]
            optionalWords STOPWORDS
          end

          add_index Offer.remote_index_name(locale),
                    disable_indexing: Rails.env.test?,
                    if: :remote_indexable? do
            attributesToIndex index
            attribute(:name) { send("name_#{locale}") }
            attribute(:description) { send("description_#{locale}") }
            attribute(:next_steps)  { _next_steps locale }
            attribute(:lang) { lang(locale) }
            attribute(:_tags) { _tags(locale) }
            attribute(:_stamp_family) { _stamp_family(locale) }
            attribute(:_stamp_refugees) { _stamp_refugees(locale) }
            attribute(:category_names)  { category_names(locale) }
            add_attribute(*attributes)
            add_attribute :area_minlat, :area_maxlat, :area_minlong,
                          :area_maxlong
            add_attribute(*facets)
            attributesForFaceting facets + [:_tags, :encounter]
            optionalWords STOPWORDS

            # no geo necessary
            ranking %w(typo words proximity attribute exact custom)
          end
        end
      end

      def personal_indexable?
        approved? && personal?
      end

      def remote_indexable?
        approved? && !personal?
      end

      def personal?
        encounter == 'personal'
      end

      # Offer's location's geo coordinates for indexing
      def _geoloc
        {
          'lat' => location.try(:latitude) || '0.0',
          'lng' => location.try(:longitude) || '0.0'
        }
      end

      # Offer's categories for indexing
      def _tags locale = :de
        tags = []
        categories.find_each do |category|
          tags << category.self_and_ancestors.map { |cate| cate.name(locale) }
        end
        tags.flatten.uniq
      end

      # lang attribute for translate markup
      def lang locale
        if translations.find_by(locale: locale).try(:automated?)
          "#{locale}-x-mtfrom-de"
        else
          locale.to_s
        end
      end

      # additional searchable string made from categories (localized for attribute)
      def category_names locale = :de
        _tags(locale).join ' '
      end

      # additional searchable string made from keywords
      def keyword_string
        keywords.pluck(:name, :synonyms).flatten.compact.uniq.join(', ')
      end

      # concatenated organization name for search index
      def organization_names
        organizations.pluck(:name).join(', ')
      end

      def location_visible
        location ? location.visible : false
      end

      # filter indexing methods
      %w(target_audience language section).each do |filter|
        define_method "_#{filter}_filters" do
          send("#{filter}_filters").pluck(:identifier)
        end
      end

      def _age_filters
        (age_from..age_to).to_a
      end

      def _exclusive_gender_filters
        [exclusive_gender]
      end

      def _next_steps locale
        string = next_steps_for_locale(locale)
        string.empty? ? send("old_next_steps_#{locale}") : string
      end

      # stamp-generation methods for each section
      def _stamp_family locale
        Offerstamp.generate_stamp self, 'family', locale
      end

      def _stamp_refugees locale
        Offerstamp.generate_stamp self, 'refugees', locale
      end
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
