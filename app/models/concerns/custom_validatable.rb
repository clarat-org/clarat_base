module CustomValidatable
  extend ActiveSupport::Concern

  included do
    # def fail_validation field, i18n_selector, options = {}
    #   errors.add(field, I18n.t(
    #                       "#{self.class.name.downcase}.validations.#{i18n_selector}", options
    #   ))
    # end
  end
end
