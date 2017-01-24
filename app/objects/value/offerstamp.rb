# This module represents the entire offer state machine and should stay
# together
# rubocop:disable Metrics/ClassLength
class Offerstamp
  def self.generate_stamp offer, current_section, locale
    # filter target_audience array to only include those of the current_section
    target_audience_for_section = offer.target_audience_filters
                                       .pluck(:identifier)
                                       .select { |ta| ta.index(current_section) == 0 }
    # return empty string if there is not exactly one target_audience
    return '' unless target_audience_for_section.length == 1
    # generate frontend stamp
    generate_offer_stamp current_section, offer, target_audience_for_section[0],
                         locale
  end

  private_class_method

  def self.generate_offer_stamp current_section, offer, ta, locale
    locale_entry = 'offer.stamp.target_audience.' + ta.to_s
    target_audiences_with_advanced_logic =
      %w(family_children family_parents family_nuclear_family
         family_parents_to_be refugees_children refugees_parents_to_be
         refugees_umf refugees_parents refugees_families refugees_general)

    if target_audiences_with_advanced_logic.include?(ta)
      locale_entry += send("stamp_#{ta}", offer)
    end
    stamp = I18n.t(locale_entry, locale: locale)

    stamp = stamp_add_age offer, ta, stamp, current_section, locale
    stamp_add_residence_status offer, stamp, locale, current_section
  end

  # --------- FAMILY

  def self.stamp_family_children offer
    if !offer.gender_first_part_of_stamp.nil?
      ".#{offer.gender_first_part_of_stamp}"
    elsif offer.age_from >= 14 && offer.age_to >= 14
      '.adolescents'
    elsif offer.age_from < 14 && offer.age_to >= 14
      '.and_adolescents'
    else
      '.default'
    end
  end

  def self.stamp_family_parents offer
    locale_entry = '.' + (offer.gender_first_part_of_stamp.nil? ? 'neutral' : offer.gender_first_part_of_stamp)
    locale_entry += '.' + (offer.gender_second_part_of_stamp.nil? ? 'neutral' : offer.gender_second_part_of_stamp)
    locale_entry
  end

  def self.stamp_family_nuclear_family offer
    if offer.gender_first_part_of_stamp.nil? &&
       (offer.gender_second_part_of_stamp.nil? || stamp_family_nuclear_family_default_special(offer))
      '.default'
    else
      locale_entry = '.' + (offer.gender_first_part_of_stamp.nil? ? 'neutral' : offer.gender_first_part_of_stamp)
      locale_entry + stamp_family_nuclear_family_gender_second_part(offer)
    end
  end

  # (...)
  def self.stamp_family_nuclear_family_default_special offer
    offer.gender_second_part_of_stamp == 'neutral' && !offer.age_visible && offer.age_to > 1
  end

  def self.stamp_family_nuclear_family_gender_second_part offer
    if offer.gender_second_part_of_stamp == 'neutral' && offer.age_from == 0 && offer.age_to == 1
      '.with_baby'
    else
      '.' + (offer.gender_second_part_of_stamp.nil? ? 'neutral' : offer.gender_second_part_of_stamp)
    end
  end

  def self.stamp_family_parents_to_be offer
    if offer.gender_first_part_of_stamp.nil? &&
       offer.gender_second_part_of_stamp.nil?
      '.default'
    else
      locale_entry = '.' + (offer.gender_first_part_of_stamp.nil? ? 'neutral' : offer.gender_first_part_of_stamp)
      locale_entry += '.' + (offer.gender_second_part_of_stamp.nil? ? 'default' : offer.gender_second_part_of_stamp)
      locale_entry
    end
  end

  # --------- REFUGEES

  def self.stamp_refugees_children offer
    if !offer.gender_first_part_of_stamp.nil?
      ".#{offer.gender_first_part_of_stamp}"
    elsif offer.age_from >= 14 && offer.age_to >= 14
      '.adolescents'
    elsif offer.age_from < 14 && offer.age_to >= 14
      '.and_adolescents'
    else
      '.default'
    end
  end

  def self.stamp_refugees_umf offer
    offer.gender_first_part_of_stamp.nil? ? '.neutral' : '.' + offer.gender_first_part_of_stamp
  end

  # follows the same logic as self.stamp_refugees_umf
  def self.stamp_refugees_parents_to_be offer
    stamp_refugees_umf(offer)
  end

  def self.stamp_refugees_parents offer
    locale_entry = offer.gender_first_part_of_stamp.nil? ? '.neutral' : '.' + offer.gender_first_part_of_stamp
    locale_entry += offer.gender_second_part_of_stamp.nil? ? '.neutral' : '.' + offer.gender_second_part_of_stamp
    locale_entry
  end

  def self.stamp_refugees_families offer
    if offer.gender_first_part_of_stamp.nil? &&
       offer.gender_second_part_of_stamp.nil?
      '.default'
    else
      locale_entry = '.' + (offer.gender_first_part_of_stamp.nil? ? 'neutral' : offer.gender_first_part_of_stamp)
      locale_entry + stamp_family_nuclear_family_gender_second_part(offer)
    end
  end

  def self.stamp_refugees_general offer
    locale_entry = offer.gender_first_part_of_stamp.nil? ? '.neutral' : '.' + offer.gender_first_part_of_stamp
    if offer.gender_first_part_of_stamp == 'male' || offer.gender_first_part_of_stamp == 'female'
      locale_entry += offer.age_from >= 18 ? '.default' : '.special'
    end
    locale_entry
  end

  #  TODO: formatting, account for different languages...
  def self.stamp_add_residence_status offer, stamp, locale, current_section
    if current_section == 'refugees' && offer.residence_status.blank? == false
      locale_entry = "offer.stamp.status.#{offer.residence_status}"
      stamp + ' ' + I18n.t(locale_entry, locale: locale)
    else
      stamp
    end
  end

  # --------- GENERAL (AGE)

  def self.stamp_add_age offer, ta, stamp, current_section, locale
    append_age = offer.age_visible && stamp_append_age?(offer, ta)
    child_age = stamp_child_age? offer, ta

    if append_age
      stamp += generate_age_for_stamp(
        offer.age_from,
        offer.age_to,
        child_age ? "#{I18n.t('offer.stamp.age.of_child', locale: locale)} " : '',
        current_section,
        locale
      )
    end
    stamp
  end

  def self.stamp_append_age? offer, ta
    ta != 'family_everyone' &&
      !(ta == 'family_nuclear_family' && offer.gender_first_part_of_stamp.nil? &&
        offer.gender_second_part_of_stamp.nil?)
  end

  def self.stamp_child_age? offer, ta
    %w(family_parents family_relatives refugees_parents).include?(ta) &&
      !offer.gender_second_part_of_stamp.nil? &&
      offer.gender_second_part_of_stamp == 'neutral'
  end

  def self.generate_age_for_stamp from, to, prefix, current_section, locale
    age_string =
      prefix +
      if from == 0
        "#{I18n.t('offer.stamp.age.to', locale: locale)} #{to}"
      elsif to == 99 || current_section == 'family' && to > 17
        "#{I18n.t('offer.stamp.age.from', locale: locale)} #{from}"
      elsif from == to
        from.to_s
      else
        "#{from} - #{to}"
      end
    " (#{age_string} #{I18n.t('offer.stamp.age.suffix', locale: locale, count: to)})"
  end
end
# rubocop:enable Metrics/ClassLength
