require_relative '../test_helper'

describe UserTeam do
  let(:user_team) { UserTeam.new }
  subject { user_team }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :name }
  end

  describe 'relations' do
    it { subject.must have_many :user_team_users }
    it { subject.must have_many(:users).through :user_team_users }
    it { subject.must have_many :current_users }
    it { subject.must have_many :productivity_goals }
    it { subject.must have_many :statistics }
  end
end
