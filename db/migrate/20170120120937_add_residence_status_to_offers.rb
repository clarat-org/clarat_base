class AddResidenceStatusToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :residence_status, :string, null: true

    # Transfer Data: only change TargetAudienceFilter
    old_ta = TargetAudienceFilter.find_by(identifier: 'refugees_adolescents')
    if old_ta
      new_ta = TargetAudienceFilter.find_by(identifier: 'refugees_children')
      old_ta.offers.map do |o|
        o.target_audience_filters.delete(old_ta)
        o.target_audience_filters << new_ta
      end
    end

    old_ta = TargetAudienceFilter.find_by(identifier: 'refugees_children_and_adolescents')
    if old_ta
      new_ta = TargetAudienceFilter.find_by(identifier: 'refugees_children')
      old_ta.offers.map do |o|
        o.target_audience_filters.delete(old_ta)
        o.target_audience_filters << new_ta
      end
    end

    old_ta = TargetAudienceFilter.find_by(identifier: 'refugees_ujf')
    if old_ta
      new_ta = TargetAudienceFilter.find_by(identifier: 'refugees_umf')
      old_ta.offers.map do |o|
        o.target_audience_filters.delete(old_ta)
        o.target_audience_filters << new_ta
      end
    end

    # Transfer Data: change TargetAudienceFilter and set residence_status
    old_ta = TargetAudienceFilter.find_by(identifier: 'refugees_pre_asylum_procedure')
    if old_ta
      new_ta = TargetAudienceFilter.find_by(identifier: 'refugees_general')
      old_ta.offers.map do |o|
        o.target_audience_filters.delete(old_ta)
        o.target_audience_filters << new_ta
        o.update_columns residence_status: 'before_asylum_application'
      end
    end

    old_ta = TargetAudienceFilter.find_by(identifier: 'refugees_asylum_procedure')
    if old_ta
      new_ta = TargetAudienceFilter.find_by(identifier: 'refugees_general')
      old_ta.offers.map do |o|
        o.target_audience_filters.delete(old_ta)
        o.target_audience_filters << new_ta
        o.update_columns residence_status: 'asylum_procedure'
      end
    end

    old_ta = TargetAudienceFilter.find_by(identifier: 'refugees_residence_permit')
    if old_ta
      new_ta = TargetAudienceFilter.find_by(identifier: 'refugees_general')
      old_ta.offers.map do |o|
        o.target_audience_filters.delete(old_ta)
        o.target_audience_filters << new_ta
        o.update_columns residence_status: 'residence_permit' # TODO: final wording?!?!
      end
    end

    old_ta = TargetAudienceFilter.find_by(identifier: 'refugees_deportation_decision')
    if old_ta
      new_ta = TargetAudienceFilter.find_by(identifier: 'refugees_general')
      old_ta.offers.map do |o|
        o.target_audience_filters.delete(old_ta)
        o.target_audience_filters << new_ta
        o.update_columns residence_status: 'deportation_decision'
      end
    end

    old_ta = TargetAudienceFilter.find_by(identifier: 'refugees_toleration_decision')
    if old_ta
      new_ta = TargetAudienceFilter.find_by(identifier: 'refugees_general')
      old_ta.offers.map do |o|
        o.target_audience_filters.delete(old_ta)
        o.target_audience_filters << new_ta
        o.update_columns residence_status: 'toleration_decision' # TODO: final wording?!?!
      end
    end

    # Deploy TODO's:
    # IDENTIFIERS_TO_DELETE =
    #   %w(refugees_adolescents refugees_children_and_adolescents refugees_ujf
    #      refugees_pre_asylum_procedure refugees_asylum_procedure
    #      refugees_deportation_decision refugees_toleration_decision
    #      refugees_residence_permit).freeze
    # create new TargetAudienceFilter
    # TargetAudienceFilter.create!(
    #   identifier: 'refugees_parents_to_be',
    #   name: 'geflüchtete werdende Eltern',
    #   section_filter_id: SectionFilter.find_by(identifier: 'refugees').id
    # )
    # TODO: delete TargetAudienceFilters from list
    # TODO: reindex all offers with refugees TargetAudienceFilter
  end
end
