require_relative '../test_helper'

describe DefinitionsOffer do
  let(:definitions_offer) { DefinitionsOffer.new }

  subject { definitions_offer }

  it { subject.must_be :valid? }

  describe 'attributes' do
    it { subject.must_respond_to :offer_id }
    it { subject.must_respond_to :definition_id }
  end
end
