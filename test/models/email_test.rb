require_relative '../test_helper'

describe Email do
  let(:email) { Email.new address: 'a@b.c' }
  subject { email }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :address }
    it { subject.must_respond_to :aasm_state }
    it { subject.must_respond_to :security_code }
    it { subject.must_respond_to :created_at }
    it { subject.must_respond_to :updated_at }

    it { subject.must_respond_to :given_security_code }
  end

  describe 'validations' do
    describe 'always' do
      it { subject.must validate_presence_of :address }
      it { subject.must validate_uniqueness_of :address }
      it { subject.must validate_length_of(:address).is_at_most 64 }
      it { subject.must validate_length_of(:address).is_at_least 3 }
    end

    describe 'on update' do
      let(:email) { Email.create! address: 'a@b.c' }
      it { subject.must validate_presence_of :security_code }
    end
  end

  describe 'state machine' do
    describe 'initial' do
      it 'must be uninformed by default' do
        subject.must_be :uninformed?
      end

      it 'wont yet have a security code' do
        subject.security_code.must_be :nil?
      end
    end

    # describe '#inform' do
      # subject { email.inform }
      #
      # describe 'when assigned to contact people with approved offers' do
      #   let(:email) { FactoryGirl.create :email, :with_approved_offer }
      #
      #   it 'wont be possible from informed' do
      #     email.aasm_state = 'informed'
      #     assert_raises(AASM::InvalidTransition) { subject }
      #   end
      #
      #   it 'wont be possible from subscribed' do
      #     email.aasm_state = 'subscribed'
      #     assert_raises(AASM::InvalidTransition) { subject }
      #   end
      #
      #   it 'wont be possible from unsubscribed' do
      #     email.aasm_state = 'unsubscribed'
      #     assert_raises(AASM::InvalidTransition) { subject }
      #   end
      # end
    # end

    describe '#subscribe' do
      let(:email) { FactoryGirl.create :email, :with_security_code }
      subject { email.subscribe }

      describe 'with a correct security key' do
        before { email.given_security_code = email.security_code }

        it 'should be possible from informed' do
          email.aasm_state = 'informed'
          subject.must_equal true
          email.subscribed?.must_equal true
        end

        it 'wont be possible from uninformed' do
          email.aasm_state = 'uninformed'
          assert_raises(AASM::InvalidTransition) { subject }
        end

        it 'wont be possible from subscribed' do
          email.aasm_state = 'subscribed'
          assert_raises(AASM::InvalidTransition) { subject }
        end

        it 'should be possible from unsubscribed' do
          email.aasm_state = 'unsubscribed'
          subject.must_equal true
          email.subscribed?.must_equal true
        end
      end

      describe 'with an incorrect security key' do
        before { email.given_security_code = 'incorrect' }

        it 'shouldnt be possible from informed and wont generate a new key' do
          email.aasm_state = 'informed'
          email.expects(:regenerate_security_code).never
          assert_raises(AASM::InvalidTransition) { subject }
        end
      end
    end

    describe '#unsubscribe' do
      subject { email.unsubscribe }

      it 'should be possible from subscribed' do
        email.aasm_state = 'subscribed'
        subject.must_equal true
        email.unsubscribed?.must_equal true
      end

      it 'wont be possible from uninformed' do
        email.aasm_state = 'uninformed'
        assert_raises(AASM::InvalidTransition) { subject }
        email.unsubscribed?.must_equal false
      end

      it 'wont be possible from informed' do
        email.aasm_state = 'informed'
        assert_raises(AASM::InvalidTransition) { subject }
        email.unsubscribed?.must_equal false
      end

      it 'wont be possible from unsubscribed' do
        email.aasm_state = 'unsubscribed'
        assert_raises(AASM::InvalidTransition) { subject }
      end
    end
  end

  describe 'Methods' do
    describe '#should_be_blocked?' do
      it 'should return true if it has SPoC contact_people' do
        email = FactoryGirl.create :email
        FactoryGirl.create :contact_person, spoc: true, email: email
        email.send(:should_be_blocked?).must_equal true
      end

      it 'should return false if it has no SPoC contact_people' do
        email = FactoryGirl.create :email
        FactoryGirl.create :contact_person, spoc: false, email: email
        email.send(:should_be_blocked?).must_equal false
      end
    end

    # describe '#informable?' do
    #   it 'should be true if it has approved offers & a mailings_enabled orga' do
    #     email = FactoryGirl.create :email
    #     offer = FactoryGirl.create :offer, :approved
    #     offer.contact_people.first.update_column :email_id, email.id
    #     email.organizations.first.update_column :mailings_enabled, true
    #     email.send(:informable?).must_equal true
    #   end
    #
    #   it 'should be false if it has no approved offers' do
    #     email = FactoryGirl.create :email
    #     offer = FactoryGirl.create :offer
    #     offer.contact_people.first.update_column :email_id, email.id
    #     email.organizations.first.update_column :mailings_enabled, true
    #     email.send(:informable?).must_equal false
    #   end
    #
    #   it 'should be false if it has no mailings_enabled orga' do
    #     email = FactoryGirl.create :email
    #     offer = FactoryGirl.create :offer, :approved
    #     offer.contact_people.first.update_column :email_id, email.id
    #     email.organizations.first.update_column :mailings_enabled, false
    #     email.send(:informable?).must_equal false
    #   end
    # end
  end
end
