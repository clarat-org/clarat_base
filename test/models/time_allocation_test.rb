require_relative '../test_helper'

describe TimeAllocation do
  let(:time_allocation) { TimeAllocation.new }
  subject { time_allocation }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :year }
    it { subject.must_respond_to :week_number }
    it { subject.must_respond_to :desired_wa_hours }
    it { subject.must_respond_to :actual_wa_hours }
  end

  describe 'relations' do
    it { subject.must belong_to :user }
  end
end
