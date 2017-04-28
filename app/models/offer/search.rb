class Offer
  module Search
    extend ActiveSupport::Concern

    included do
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

      def personal_indexable?
        visible_in_frontend? && personal?
      end

      def remote_indexable?
        visible_in_frontend? && !personal?
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
      %w(target_audience language).each do |filter|
        define_method "_#{filter}_filters" do
          send("#{filter}_filters").pluck(:identifier)
        end
      end

      def _age_filters
        (age_from..age_to).to_a
      end

      def _exclusive_gender_filters
        [gender_first_part_of_stamp]
      end

      def _next_steps locale
        string = next_steps_for_locale(locale)
        string.empty? ? send("old_next_steps_#{locale}") : string
      end
    end
  end
end
