#
# y /|\
#    |     @   <- an instance of this model
#    |
#    +------->
#           x (date)
# #topic => the topic / category that this point belongs to
# #user => Reference to the one this point is about
class Statistic < ActiveRecord::Base
  # Associations
  belongs_to :user, inverse_of: :statistics
  belongs_to :user_team, inverse_of: :statistics

  # Enumerization
  extend Enumerize
  TOPICS = %w(
    offer_created offer_approved organization_created organization_approved
  ).freeze
  enumerize :topic, in: TOPICS

  # Scopes
  default_scope { order('date ASC') }
  TOPICS.each do |topic|
    scope topic.to_sym, -> { where(topic: topic) }
  end
end
