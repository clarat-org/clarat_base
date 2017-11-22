require_relative '../test_helper'

describe StatisticTransition do
  let(:statistic_transition) { statistic_transitions(:basic) }
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

  describe 'statistic_charts' do
    before do
      @statistic_chart = statistic_charts(:basic)
      subject.statistic_charts << @statistic_chart
      @statistic_chart_transition = subject.statistic_chart_transitions.first
      subject.destroy
    end

    it 'will destroy statistic chart goals' do
      assert_raises(ActiveRecord::RecordNotFound) do
        @statistic_chart_transition.reload
      end
    end

    it 'will not destroy statistic charts' do
      refute_nil @statistic_chart.reload
    end
  end
end
