class LocationObserver < ActiveRecord::Observer
  def after_commit l
    # queue geocoding
    if l.previous_changes.key?(:street || :zip || :city_id || :federal_state_id)
      GeocodingWorker.perform_async l.id
    end

    # update algolia indices of offers (for location_visible) if changed
    if l.previous_changes.key?(:visible)
      l.offers.visible_in_frontend.find_each(&:index!)
    end
  end
end
