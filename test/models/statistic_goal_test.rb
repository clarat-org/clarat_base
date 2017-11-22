require_relative '../test_helper'

describe StatisticGoal do
  let(:statistic_goal) { statistic_goals(:basic) }
  subject { statistic_goal }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :amount }
    it { subject.must_respond_to :starts_at }
  end

  describe 'relations' do
    it { subject.must have_many :statistic_chart_goals }
    it do
      subject.must have_many(:statistic_charts).through :statistic_chart_goals
    end
  end

  describe 'statistic_charts' do
    before do
      @statistic_chart = statistic_charts(:basic)
      subject.statistic_charts << @statistic_chart
      @statistic_chart_goal = subject.statistic_chart_goals.first
      subject.destroy
    end

    it 'will destroy statistic chart goals' do
      assert_raises(ActiveRecord::RecordNotFound) do
        @statistic_chart_goal.reload
      end
    end

    it 'will not destroy statistic charts' do
      refute_nil @statistic_chart.reload
    end
  end
end
