class Absence < ActiveRecord::Base
  # Associations
  belongs_to :user, inverse_of: :absences
end
