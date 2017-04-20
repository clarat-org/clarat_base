# Connector model
class DefinitionOffer < ActiveRecord::Base
  belongs_to :offer
  belongs_to :definition
end
