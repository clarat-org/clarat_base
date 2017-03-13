require_relative '../test_helper'

describe StatisticChart do
  let(:statistic_chart) { StatisticChart.new }
  subject { statistic_chart }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :title }
    it { subject.must_respond_to :starts_at }
    it { subject.must_respond_to :ends_at }
    # it { subject.must_respond_to :target_model }
    # it { subject.must_respond_to :target_count }
    # it { subject.must_respond_to :target_field_name }
    # it { subject.must_respond_to :target_field_value }
  end

  describe 'relations' do
    it { subject.must belong_to :user_team }
    it { subject.must belong_to :user }
    it { subject.must have_many :statistic_chart_transitions }
    it { subject.must have_many :statistic_chart_goals }
  end
end
