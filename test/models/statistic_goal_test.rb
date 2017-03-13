require_relative '../test_helper'

describe StatisticGoal do
  let(:statistic_goal) { StatisticGoal.new }
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
end
