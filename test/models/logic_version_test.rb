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

  describe 'validations' do
    it { subject.must validate_presence_of :name }
    it { subject.must validate_uniqueness_of :name }
    it { subject.must validate_presence_of :version }
    it { subject.must validate_uniqueness_of :version }
  end
end
