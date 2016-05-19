module ClaratBase
  class Engine < ::Rails::Engine
    require 'enumerize'
    require 'rails-observers'
    require 'paper_trail'
    require 'sanitize'
    require 'closure_tree'
    require 'aasm'
    require 'friendly_id'
    require 'geocoder'
    require 'redcarpet'
    require 'algoliasearch-rails'
    require 'sidekiq'
    # require 'sinatra'
    # require 'sidetiq'
    require 'easy_translate'

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(
      #{config.root}/app/objects/service/
      #{config.root}/app/objects/value/
      #{config.root}/app/observers/
      #{config.root}/app/models/filters/
      #{config.root}/app/workers/
    )

    # Activate observers that should always be running.
    config.active_record.observers = %w(
      LocationObserver SubscriptionObserver ContactObserver OfferObserver
      OrganizationObserver
    )

    # Also store migrations here
    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
      end
    end
  end
end
