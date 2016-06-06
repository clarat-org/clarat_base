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
    it { subject.must_respond_to :umbrella }
    it { subject.must_respond_to :slug }
    it { subject.must_respond_to :created_at }
    it { subject.must_respond_to :updated_at }
    it { subject.must_respond_to :aasm_state }
    it { subject.must_respond_to :mailings_enabled }
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
    end
  end

  describe 'associations' do
    # What about has_many_through
    it { subject.must have_many :offers }
    it { subject.must have_many :locations }
    it { subject.must have_many :hyperlinks }
    it { subject.must have_many :websites }
    it { subject.must have_many(:section_filters).through :offers }
  end

  describe 'Observer' do
    describe 'before_create' do
      it 'should not change a created_by' do
        organization.created_by = 123
        organization.save!
        organization.created_by.must_equal 123
      end

      it 'should set created_by if it doesnt exist' do
        organization.created_by = nil
        organization.save!
        organization.created_by.must_equal ::PaperTrail.whodunnit
        # Note we have a spec helper for PaperTrail
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

      it 'should approve with a different actor' do
        organization.stubs(:different_actor?).returns(true)
        organization.approve
        organization.must_be :approved?
      end

      # it 'wont approve with the same actor' do
      #   organization.stubs(:different_actor?).returns(false)
      #   assert_raises(AASM::InvalidTransition) { organization.approve }
      #   organization.must_be :completed?
      # end

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
      it 'should reactivate an associated organization_deactivated offer' do
        offer.update_column :aasm_state, :organization_deactivated
        orga.reactivate_offers!
        offer.reload.must_be :approved?
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
      it 'should deactivate an offer belonging to this organization' do
        orga.offers.first.must_be :approved?
        orga.website_under_construction!
        orga.offers.first.must_be :under_construction_post?
      end

      it 'should should work from deactivated state with offers' do
        orga.offers.first.must_be :approved?
        orga.deactivate_internal!
        orga.offers.first.must_be :organization_deactivated?
        orga.website_under_construction!
        orga.offers.first.must_be :under_construction_post?
      end

      it 'should raise an error when deactivation fails for an offer' do
        Offer.any_instance.expects(:website_under_construction!)
             .returns(false)

        assert_raise(RuntimeError) { orga.deactivate_offers_to_under_construction! }
      end
    end

    describe 'reactivate_offers_from_under_construction! pre approve' do
      let(:offer) { offers(:basic) }
      it 'should reactivate associated under_construction offers' do
        offer.update_column :aasm_state, :under_construction_pre
        orga.reactivate_offers_from_under_construction!
        offer.reload.must_be :initialized?
      end

      it 'should raise an error when deactivation fails for an offer' do
        Offer.any_instance.expects(:website_under_construction!)
             .returns(false)

        assert_raise(RuntimeError) { orga.deactivate_offers_to_under_construction! }
      end
    end

    describe 'reactivate_offers_from_under_construction! post approve' do
      let(:offer) { offers(:basic) }
      it 'should reactivate associated under_construction offers' do
        offer.update_column :aasm_state, :under_construction_post
        orga.reactivate_offers_from_under_construction!
        offer.reload.must_be :approved?
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

  describe 'translation' do
    it 'should always get de translation, others only when not initialized' do
      new_orga = FactoryGirl.create(:organization)
      new_orga.translations.count.must_equal 1 # only :de
      new_orga.update_columns aasm_state: 'completed'
      OrganizationObserver.send(:new).after_save(new_orga)
      new_orga.translations.count.must_equal I18n.available_locales.count
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
end
