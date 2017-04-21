module Translation
  extend ActiveSupport::Concern

  included do
    def self.translate *fields
      fields.each do |field|
        define_field_getter(field)
        define_untranslated_field_getter(field)
        I18n.available_locales.each do |locale|
          define_specific_locale_field_getter(field, locale)
        end
      end

      define_translated_fields_list_getter(fields)
    end

    has_many :translations, class_name: "#{self.name}Translation",
                            inverse_of: self.name.underscore,
                            dependent: :destroy

    def translation_automated?
      return false unless translation
      translation.automated?
    end

    def translation
      @_translation ||= translations.find_by(locale: I18n.locale)
    end

    # cache key always needs locale
    def cache_key
      super + I18n.locale.to_s
    end

    def changed_translatable_fields
      changes = self.previous_changes
      translated_fields.select { |f| changes[f.to_s] }
    end

    private

    # :name -> translated #name getter in currently set locale
    def self.define_field_getter field
      define_method field do
        if translation && !translation.send(field).blank?
          translation.send(field)
        else
          send("untranslated_#{field}")
        end
      end
    end

    # :name -> #untranslated_name as regular #name getter
    def self.define_untranslated_field_getter field
      define_method "untranslated_#{field}" do
        attributes[field.to_s]
      end
    end

    # :name, :de -> translated #name_de getter in specific given locale
    def self.define_specific_locale_field_getter field, locale
      define_method "#{field}_#{locale}" do
        translation = translations.where(locale: locale).select(field).first
        return nil unless translation
        translation.send(field)
      end
    end

    # simple getter for all fields that are translated for this object
    def self.define_translated_fields_list_getter fields
      define_method :translated_fields do
        fields
      end
    end
  end
end
