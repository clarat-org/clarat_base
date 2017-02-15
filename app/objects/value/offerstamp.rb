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

    if %w(family_children family_parents family_nuclear_family refugees_general
          family_parents_to_be refugees_children refugees_parents_to_be
          refugees_umf refugees_parents refugees_families ).include?(ta)
      locale_entry += send("stamp_#{ta}", offer)
    end
    # build separate parts of stamp and join them with locale-specific format
    stamp = I18n.t(locale_entry, locale: locale)
    optional_age = stamp_optional_age(offer, ta, current_section, locale)
    optional_status = stamp_optional_residency_status(offer, locale, current_section)
    I18n.t('offer.stamp.format', locale: locale,
                                 stamp: stamp,
                                 optional_age: optional_age,
                                 optional_status: optional_status)
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
    locale_entry + stamp_refugees_general_adult_special(offer)
  end

  def self.stamp_refugees_general_adult_special offer
    if offer.gender_first_part_of_stamp.blank? || offer.gender_first_part_of_stamp == 'neutral'
      offer.age_to >= 18 && offer.age_from >= 18 ? '.adults' : '.neutral'
    else
      ''
    end
  end

  def self.stamp_optional_residency_status offer, locale, current_section
    if current_section == 'refugees' && offer.residency_status.blank? == false
      locale_entry = "offer.stamp.status.#{offer.residency_status}"
      " #{I18n.t(locale_entry, locale: locale)}"
    else
      ''
    end
  end

  # --------- GENERAL (AGE)

  def self.stamp_optional_age offer, ta, current_section, locale
    append_age = offer.age_visible && stamp_append_age?(offer, ta)
    child_age = stamp_child_age? offer, ta

    if append_age
      age_string = generate_age_for_stamp(
        offer.age_from,
        offer.age_to,
        current_section,
        locale
      )
      " (#{child_age ? I18n.t('offer.stamp.age.age_of_child', locale: locale, age: age_string) : age_string})"
    else
      ''
    end
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

  def self.generate_age_for_stamp from, to, current_section, locale
    if from == 0
      I18n.t('offer.stamp.age.age_to', locale: locale, count: to)
    elsif to == 99 || current_section == 'family' && to > 17
      I18n.t('offer.stamp.age.age_from', locale: locale, count: from)
    elsif from == to
      "#{from} #{I18n.t('offer.stamp.age.suffix', locale: locale)}"
    else
      "#{from} – #{to} #{I18n.t('offer.stamp.age.suffix', locale: locale)}"
    end
  end
end
# rubocop:enable Metrics/ClassLength
