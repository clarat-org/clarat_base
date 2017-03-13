require_relative '../test_helper'

describe StatisticTransition do
  let(:statistic_transition) { StatisticTransition.new }
  subject { statistic_transition }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :klass_name }
    it { subject.must_respond_to :field_name }
    it { subject.must_respond_to :start_value }
    it { subject.must_respond_to :end_value }
  end

  describe 'relations' do
    it { subject.must have_many :statistic_chart_transitions }
    it do
      subject.must have_many(:statistic_charts)
        .through(:statistic_chart_transitions)
    end
  end
end
