class LocationObserver < ActiveRecord::Observer
  def after_save l
    # queue geocoding
    if l.street_changed? || l.zip_changed? || l.city_changed? ||
       l.federal_state_id_changed?
      GeocodingWorker.perform_async l.id
    end

    # update algolia indices of offers (for location_visible) if changed
    if l.visible_changed?
      l.offers.approved.find_each(&:index!)
    end
  end
end
