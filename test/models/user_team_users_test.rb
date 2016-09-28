require_relative '../test_helper'

describe UserTeamUser do
  let(:user_team_users) { UserTeamUser.new }
  subject { user_team_users }

  describe 'attributes' do
    it { subject.must_respond_to :id }
  end

  describe 'relations' do
    it { subject.must belong_to :user }
    it { subject.must belong_to :user_team }
  end
end
