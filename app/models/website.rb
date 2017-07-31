# The external web addresses of organizations and offers.
class Website < ActiveRecord::Base
  UNREACHABLE_THRESHOLD = 2

  # Associations
  has_many :hyperlinks, dependent: :destroy
  has_many :organizations, inverse_of: :website
  has_many :offers, through: :hyperlinks, inverse_of: :websites,
                    source: :linkable, source_type: 'Offer'
  has_many :divisions, through: :hyperlinks, inverse_of: :websites,
                       source: :linkable, source_type: 'Division'

  # Enumerization
  extend Enumerize
  HOSTS = %w(own facebook twitter youtube gplus pinterest document
             online_consulting chat forum online_course application_form
             contact_form other).freeze
  enumerize :host, in: HOSTS

  # Scopes..
  # .. by hostname
  HOSTS.each { |host_name| scope host_name, -> { where(host: host_name) } }
  # .. by url
  scope :pdf, -> { where('websites.url LIKE ?', '%.pdf') }
  scope :non_pdf, -> { where.not('websites.url LIKE ?', '%.pdf') }

  # Methods
  def unreachable?
    unreachable_count >= UNREACHABLE_THRESHOLD
  end
end
