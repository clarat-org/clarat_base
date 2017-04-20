# Connector model
class DefinitionOrganization < ActiveRecord::Base
  belongs_to :organization
  belongs_to :definition
end
