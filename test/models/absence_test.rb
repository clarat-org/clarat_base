require_relative '../test_helper'

describe Absence do
  let(:absence) { Absence.new }
  subject { absence }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :starts_at }
    it { subject.must_respond_to :ends_at }
    it { subject.must_respond_to :sync }
  end

  describe 'relations' do
    it { subject.must belong_to :user }
  end
end
