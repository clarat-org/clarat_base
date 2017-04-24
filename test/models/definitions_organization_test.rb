require_relative '../test_helper'

describe DefinitionsOrganization do
  let(:definitions_organization) { DefinitionsOrganization.new }

  subject { definitions_organization }

  it { subject.must_be :valid? }

  describe 'attributes' do
    it { subject.must_respond_to :organization_id }
    it { subject.must_respond_to :definition_id }
  end
end
