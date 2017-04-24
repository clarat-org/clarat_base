# Connector model
class DefinitionsOrganization < ActiveRecord::Base
  belongs_to :organization
  belongs_to :definition
end
