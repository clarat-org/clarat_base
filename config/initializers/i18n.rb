Rails.application.configure do
  I18n.config.enforce_available_locales = false
  I18n.available_locales = [:de, :en, :ar, :fa, :tr, :pl, :ru, :fr]

  # Fallbacks
  config.i18n.fallbacks = [:en]

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
  config.i18n.load_path += Dir[ClaratBase::Engine.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
  config.i18n.default_locale = :de

  ### GLOBALIZE GEM ###

  # Globalize.fallbacks = {
  #   de: [:de, :en],
  #   en: [:en, :de],
  #   ar: [:ar, :en, :de],
  #   fr: [:fr, :en, :de],
  #   pl: [:pl, :en, :de],
  #   tr: [:tr, :en, :de],
  #   ru: [:ru, :en, :de]
  # }
end
