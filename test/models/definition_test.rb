require_relative '../test_helper'

describe Definition do
  let(:definition) { Definition.new key: 'foo', explanation: 'bar' }
  subject { definition }

  it 'must be valid' do
    definition.must_be :valid?
  end

  describe 'attributes' do
    it { subject.must_respond_to :key }
    it { subject.must_respond_to :explanation }
  end
end
