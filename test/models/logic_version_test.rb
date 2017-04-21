require_relative '../test_helper'

describe LogicVersion do
  let(:logic_version) { LogicVersion.new }
  subject { logic_version }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :version }
    it { subject.must_respond_to :name }
    it { subject.must_respond_to :description }
  end
end
