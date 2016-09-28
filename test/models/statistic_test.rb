require_relative '../test_helper'

describe Statistic do
  let(:statistic) do
    Statistic.new topic: :offer_created, date: Date.current, count: 1
  end
  subject { statistic }

  it { subject.must_be :valid? }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :topic }
    it { subject.must_respond_to :user_id }
    it { subject.must_respond_to :date }
    it { subject.must_respond_to :count }
  end

  describe 'associations' do
    it { subject.must belong_to :user }
  end
end
