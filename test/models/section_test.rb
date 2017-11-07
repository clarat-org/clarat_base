require_relative '../test_helper'

describe Section do
  let(:family) { sections(:family) }
  subject { family }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :name }
    it { subject.must_respond_to :identifier }
  end

  describe '::Base' do
    describe 'associations' do
      it { subject.must have_many :offers }
      it { subject.must have_many(:organizations).through :divisions }
      it { subject.must have_many(:target_audience_filters) }
      it { subject.must have_many(:divisions) }
    end
  end
end
