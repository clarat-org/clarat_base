require_relative '../test_helper'

describe UserTeam do
  let(:user_team) { UserTeam.new }
  subject { user_team }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :name }
    it { subject.must_respond_to :classification }
    it { subject.must_respond_to :parent_id }
    it { subject.must_respond_to :lead_id }
  end

  describe 'relations' do
    it { subject.must have_many :user_team_users }
    it { subject.must have_many(:users).through :user_team_users }
    it { subject.must have_many(:observing_users).through :user_team_observing_users }
    it { subject.must belong_to :lead }
    it { subject.must belong_to :parent }
    it { subject.must have_many :children }
  end
end
