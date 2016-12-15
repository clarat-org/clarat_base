require_relative '../test_helper'

describe Organization do
  let(:organization) do
    Organization.new(name: 'Testname',
                     description: 'Testbeschreibung',
                     legal_form: 'ev')
  end # Necessary to test uniqueness
  let(:orga) { organizations(:basic) }

  subject { organization }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :name }
    it { subject.must_respond_to :description }
    it { subject.must_respond_to :legal_form }
    it { subject.must_respond_to :charitable }
    it { subject.must_respond_to :founded }
    it { subject.must_respond_to :slug }
    it { subject.must_respond_to :created_at }
    it { subject.must_respond_to :updated_at }
    it { subject.must_respond_to :aasm_state }
    it { subject.must_respond_to :mailings }
  end

  describe 'validations' do
    describe 'always' do # TODO: Wieso, weshalb, warum?
      # Can I test the format here as well? What about custom validations?
      it { subject.must validate_presence_of :name }
      it { subject.must validate_length_of(:name).is_at_most 100 }
      it { subject.must validate_uniqueness_of :name }
      it { subject.must validate_presence_of :description }
      it { subject.must validate_presence_of :legal_form }
      it { subject.must validate_uniqueness_of :slug }
      it { subject.must validate_presence_of :mailings }

      it 'should ensure there is exactly one hq location' do
        orga.locations.destroy_all
        orga.reload.valid?.must_equal false
        FactoryGirl.create :location, organization: orga, hq: false
        orga.reload.valid?.must_equal false
        FactoryGirl.create :location, organization: orga, hq: true
        orga.reload.valid?.must_equal true
        FactoryGirl.create :location, organization: orga, hq: true
        orga.reload.valid?.must_equal false
      end

      it 'should ensure that there are only own-websites connected' do
        orga.websites.destroy_all
        orga.reload.valid?.must_equal true
        orga.websites << FactoryGirl.create(:website, :social)
        orga.reload.valid?.must_equal false
        orga.websites.destroy_all
        orga.websites << FactoryGirl.create(:website, :own)
        orga.reload.valid?.must_equal true
      end

      it 'must have an umbrella filter' do
        orga.umbrella_filters = []
        orga.valid?.must_equal false
        orga.umbrella_filters = [filters(:diakonie)]
        orga.valid?.must_equal true
      end
    end
  end

  describe 'associations' do
    # What about has_many_through
    it { subject.must have_many :offers }
    it { subject.must have_many :locations }
    it { subject.must have_many :hyperlinks }
    it { subject.must have_many :websites }
    it { subject.must have_many(:section_filters).through :offers }
    it { subject.must have_and_belong_to_many :filters }
    it { subject.must have_and_belong_to_many :umbrella_filters }
  end

  describe 'Observer' do
    describe 'before_create' do
      it 'should not change a created_by' do
        organization.created_by = 123
        organization.umbrella_filters = [filters(:diakonie)]
        organization.save!
        organization.created_by.must_equal 123
      end

      it 'should set created_by if it doesnt exist' do
        organization.created_by = nil
        organization.umbrella_filters = [filters(:diakonie)]
        organization.save!
        organization.created_by.must_equal ::PaperTrail.whodunnit
        # Note we have a spec helper for PaperTrail
      end
    end
  end

  describe 'Scopes' do
    describe 'approved' do
      it 'should return approved offers' do
        Organization.approved.count.must_equal 1
      end

      it 'should return approved and done offers' do
        Organization.approved.count.must_equal 1
        FactoryGirl.create(:organization, aasm_state: 'all_done')
        Organization.approved.count.must_equal 2 # one approved and one done
      end
    end
  end

  describe 'State Machine' do
    describe 'initialized' do
      it 'should complete' do
        organization.complete
        organization.must_be :completed?
      end

      it 'wont approve' do
        assert_raises(AASM::InvalidTransition) { organization.approve }
        organization.must_be :initialized?
      end

      it 'wont deactivate_internal' do
        assert_raises(AASM::InvalidTransition) do
          organization.deactivate_internal
        end
        organization.must_be :initialized?
      end

      it 'wont deactivate_external' do
        assert_raises(AASM::InvalidTransition) do
          organization.deactivate_external
        end
        organization.must_be :initialized?
      end
    end

    describe 'completed' do
      before { organization.aasm_state = :completed }

      it 'should enter approval_process with a different actor' do
        organization.stubs(:different_actor?).returns(true)
        organization.start_approval_process
        organization.must_be :approval_process?
      end

      # it 'wont enter approval_process with the same actor' do
      #   organization.stubs(:different_actor?).returns(false)
      #   assert_raises(AASM::InvalidTransition) { organization.start_approval_process }
      #   organization.must_be :completed?
      # end

      it 'should enter under_construction_pre' do
        organization.website_under_construction
        organization.must_be :under_construction_pre?
      end

      it 'wont complete' do
        assert_raises(AASM::InvalidTransition) { organization.complete }
        organization.must_be :completed?
      end

      it 'wont deactivate_internal' do
        assert_raises(AASM::InvalidTransition) do
          organization.deactivate_internal
        end
        organization.must_be :completed?
      end

      it 'wont deactivate_external' do
        assert_raises(AASM::InvalidTransition) do
          organization.deactivate_external
        end
        organization.must_be :completed?
      end
    end

    describe 'approval_process' do
      before { organization.aasm_state = :approval_process }

      it 'should approve with a different actor' do
        organization.stubs(:different_actor?).returns(true)
        organization.approve
        organization.must_be :approved?
      end

      # it 'wont approve with the same actor' do
      #   organization.stubs(:different_actor?).returns(false)
      #   assert_raises(AASM::InvalidTransition) { organization.start_approval_process }
      #   organization.must_be :completed?
      # end

      it 'wont complete' do
        assert_raises(AASM::InvalidTransition) { organization.complete }
        organization.must_be :approval_process?
      end
    end

    describe 'approved' do
      before { organization.aasm_state = :approved }

      it 'wont complete' do
        assert_raises(AASM::InvalidTransition) { organization.complete }
        organization.must_be :approved?
      end

      it 'wont approve' do
        assert_raises(AASM::InvalidTransition) { organization.approve }
        organization.must_be :approved?
      end

      it 'must deactivate_internal' do
        organization.deactivate_internal
        organization.must_be :internal_feedback?
      end

      it 'must deactivate_external' do
        organization.deactivate_external
        organization.must_be :external_feedback?
      end
    end

    describe 'internal_feedback' do
      before { organization.aasm_state = :internal_feedback }

      it 'wont complete' do
        assert_raises(AASM::InvalidTransition) { organization.complete }
        organization.must_be :internal_feedback?
      end

      it 'must approve, even with same actor' do
        organization.stubs(:different_actor?).returns(false)
        organization.approve
        organization.must_be :approved?
      end

      it 'wont deactivate_internal' do
        assert_raises(AASM::InvalidTransition) do
          organization.deactivate_internal
        end
        organization.must_be :internal_feedback?
      end

      it 'must deactivate_external' do
        organization.deactivate_external
        organization.must_be :external_feedback?
      end
    end

    describe 'external_feedback' do
      before { organization.aasm_state = :external_feedback }

      it 'wont complete' do
        assert_raises(AASM::InvalidTransition) { organization.complete }
        organization.must_be :external_feedback?
      end

      it 'must approve, even with same actor' do
        organization.stubs(:different_actor?).returns(false)
        organization.approve
        organization.must_be :approved?
      end

      it 'must deactivate_internal' do
        organization.deactivate_internal
        organization.must_be :internal_feedback?
      end

      it 'wont deactivate_external' do
        assert_raises(AASM::InvalidTransition) do
          organization.deactivate_external
        end
        organization.must_be :external_feedback?
      end
    end

    describe 'all_done' do
      before { organization.aasm_state = :all_done }

      it 'must deactivate_internal' do
        organization.deactivate_internal
        organization.must_be :internal_feedback?
      end

      it 'must deactivate_external' do
        organization.deactivate_external
        organization.must_be :external_feedback?
      end

      it 'wont approve' do
        assert_raises(AASM::InvalidTransition) do
          organization.approve
        end
        organization.must_be :all_done?
      end

      it 'wont enter approval_process' do
        assert_raises(AASM::InvalidTransition) do
          organization.start_approval_process
        end
        organization.must_be :all_done?
      end
    end

    describe 'deactivate_offers!' do
      it 'should deactivate an approved offer belonging to this organization' do
        orga.offers.first.must_be :approved?
        orga.update_column :aasm_state, :internal_feedback
        orga.deactivate_offers!
        orga.offers.first.must_be :organization_deactivated?
      end

      it 'should raise an error when deactivation fails for an offer' do
        Offer.any_instance.expects(:deactivate_through_organization!)
             .returns(false)

        assert_raise(RuntimeError) { orga.deactivate_offers! }
      end
    end

    describe 'reactivate_offers!' do
      let(:offer) { offers(:basic) }
      it 'should raise a RuntimeError with stump translation-method' do
        offer.update_column :aasm_state, :organization_deactivated
        assert_raise(RuntimeError) { orga.reactivate_offers! }
        offer.reload.must_be :organization_deactivated?
      end

      it 'should reactivate an associated organization_deactivated offer' do
        # stub for translation-method stump to test functionality
        Organization.any_instance.stubs(:generate_translations!).returns true
        Offer.any_instance.stubs(:generate_translations!).returns true
        offer.update_column :aasm_state, :organization_deactivated
        orga.reactivate_offers!
        offer.reload.must_be :approved?
      end

      it 'should approve the orga and its offers when the event is used' do
        # stub for translation-method stump to test functionality
        Organization.any_instance.stubs(:generate_translations!).returns true
        Offer.any_instance.stubs(:generate_translations!).returns true
        orga.update_column :aasm_state, :internal_feedback
        offer.update_column :aasm_state, :organization_deactivated
        orga.approve_with_deactivated_offers!
        offer.reload.must_be :approved?
        orga.reload.must_be :approved?
      end

      it 'wont approve offers, that have another deactivated orga' do
        offer.update_column :aasm_state, :organization_deactivated
        offer.organizations <<
          FactoryGirl.create(:organization, aasm_state: 'external_feedback')

        orga.reactivate_offers!
        offer.reload.must_be :organization_deactivated?
      end
    end

    describe 'deactivate_offers_to_under_construction!' do
      let(:offer) { offers(:basic) }
      it 'should deactivate an offer belonging to this organization and \
          re-activate it properly' do
        # stub for translation-method stump to test functionality
        Organization.any_instance.stubs(:generate_translations!).returns true
        Offer.any_instance.stubs(:generate_translations!).returns true
        orga.offers.first.must_be :approved?
        orga.website_under_construction!
        orga.offers.first.must_be :under_construction_post?
        orga.approve_with_deactivated_offers!
        orga.offers.first.reload.must_be :approved?
      end

      it 'should work from deactivated state but ignore offers' do
        orga.offers.first.must_be :approved?
        orga.deactivate_internal!
        orga.offers.first.must_be :organization_deactivated?
        orga.website_under_construction!
        orga.offers.first.must_be :organization_deactivated?
        orga.must_be :under_construction_post?
      end

      it 'should raise an error when deactivation fails for an offer' do
        Offer.any_instance.expects(:website_under_construction!)
             .returns(false)

        assert_raise(RuntimeError) { orga.deactivate_offers_to_under_construction! }
      end
    end

    describe '#different_actor?' do
      it 'should return true when created_by differs from current_actor' do
        orga.created_by = 99
        orga.send(:different_actor?).must_equal true
      end

      it 'should return false when created_by is the same as current_actor' do
        orga.created_by = orga.current_actor
        orga.send(:different_actor?).must_equal false
      end

      it 'should return falsy when created_by is nil' do
        orga.created_by = nil
        orga.send(:different_actor?).must_equal nil
      end

      it 'should return false when current_actor is nil' do
        orga.created_by = 1
        orga.stubs(:current_actor).returns(nil)
        orga.send(:different_actor?).must_equal nil
      end
    end
  end

  describe '#homepage' do
    it 'should return the own website of the orga' do
      own_website = orga.websites.create! host: 'own', url: 'http://foo.bar'
      orga.websites.create! host: 'facebook', url: 'http://baz.fuz'
      orga.homepage.must_equal own_website
    end
  end

  describe '#location' do
    it 'should return the hq location of the orga' do
      FactoryGirl.create :location, organization: orga, hq: false # decoy
      orga.location.must_equal locations(:basic)
    end
  end

  describe '#mailings_enabled?' do
    it 'should return true for mailings=enabled' do
      orga.mailings = 'enabled'
      orga.mailings_enabled?.must_equal true
    end

    it 'should return false for any other option' do
      orga.mailings = 'disabled'
      orga.mailings_enabled?.must_equal false
      orga.mailings = 'force_disabled'
      orga.mailings_enabled?.must_equal false
      orga.mailings = 'big_player'
      orga.mailings_enabled?.must_equal false
    end
  end

  describe '#approved?' do
    it 'should return true for approved or all_done states' do
      orga.aasm_state = 'approved'
      orga.approved?.must_equal true
      orga.aasm_state = 'all_done'
      orga.approved?.must_equal true
    end

    it 'should return false for other states' do
      orga.aasm_state = 'initialized'
      orga.approved?.must_equal false
      orga.aasm_state = 'completed'
      orga.approved?.must_equal false
      orga.aasm_state = 'approval_process'
      orga.approved?.must_equal false
      orga.aasm_state = 'internal_feedback'
      orga.approved?.must_equal false
      orga.aasm_state = 'internal_feedback'
      orga.approved?.must_equal false
      orga.aasm_state = 'website_unreachable'
      orga.approved?.must_equal false
    end
  end
end
