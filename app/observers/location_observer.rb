class LocationObserver < ActiveRecord::Observer
  def after_commit l
    # queue geocoding

    if l.previous_changes.key?(:street) || l.previous_changes.key?(:zip) || l.previous_changes.key?(:city_id) || l.previous_changes.key?(:federal_state_id)
      GeocodingWorker.perform_async l.id
    end

    # update algolia indices of offers (for location_visible) if changed
    if l.previous_changes.key?(:visible)
      l.offers.visible_in_frontend.find_each(&:index!)
    end
  end
end
