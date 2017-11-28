require_relative '../test_helper'

describe User do
  let(:user) { users(:researcher) }

  subject { user }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :email }
    # it { subject.must_respond_to :encrypted_password }
    it { subject.must_respond_to :created_at }
    it { subject.must_respond_to :updated_at }
    it { subject.must_respond_to :role }
    it { subject.must_respond_to :active }
  end

  describe 'relations' do
    it { subject.must have_many(:user_teams).through :user_team_users }
    it do
      subject.must(
        have_many(:observed_user_teams).through(:user_team_observing_users)
      )
    end
    it { subject.must have_many :led_teams }
    it { subject.must have_many :statistic_charts }
    it { subject.must have_many :absences }
    it { subject.must have_many :time_allocations }
    it { subject.must have_many :created_assignments }
    it { subject.must have_many :received_assignments }
  end

  describe 'user teams' do
    before do
      @user_team = user_teams(:researcher)
      subject.user_teams << @user_team
      @user_team_user = subject.user_team_users.first
      subject.destroy
    end

    it 'will destroy connecting table' do
      assert_raises(ActiveRecord::RecordNotFound) do
        @user_team_user.reload
      end
    end

    it 'will not user teams' do
      refute_nil @user_team.reload
    end
  end

  describe 'observed user teams' do
    before do
      @user_team = user_teams(:researcher)
      subject.observed_user_teams << @user_team
      @observing_user = subject.user_team_observing_users.first
      subject.destroy
    end

    it 'will destroy connecting table' do
      assert_raises(ActiveRecord::RecordNotFound) do
        @observing_user.reload
      end
    end

    it 'will not destroy user teams' do
      refute_nil @user_team.reload
    end
  end

  # describe 'validations' do
  #   describe 'always' do
  #     it { user.must validate_presence_of :email }
  #     it { user.must validate_uniqueness_of :email }
  #   end
  # end

  describe 'methods' do
    # describe '::system_user' do
    #   it 'should find an existing system user' do
    #     factory_user = FactoryGirl.create :user, name: 'System'
    #     assert_no_difference 'User.count' do
    #       user = User.system_user
    #       user.must_equal factory_user
    #     end
    #   end
    #
    #   it 'should create a system user when none exists' do
    #     assert_difference 'User.count', 1 do
    #       User.system_user.name.must_equal 'System'
    #     end
    #   end
    # end
  end
end
