# Connector model
class DefinitionsOffer < ActiveRecord::Base
  belongs_to :offer
  belongs_to :definition
end
