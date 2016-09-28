require_relative '../test_helper'

describe ProductivityGoal do
  let(:productivity_goal) { ProductivityGoal.new }
  subject { productivity_goal }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :title }
    it { subject.must_respond_to :starts_at }
    it { subject.must_respond_to :ends_at }
    it { subject.must_respond_to :target_model }
    it { subject.must_respond_to :target_count }
    it { subject.must_respond_to :target_field_name }
    it { subject.must_respond_to :target_field_value }
  end

  describe 'relations' do
    it { subject.must belong_to :user_team }
  end
end
