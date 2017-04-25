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
        Organization.visible_in_frontend.count.must_equal 1
      end

      it 'should return approved and done offers' do
        Organization.visible_in_frontend.count.must_equal 1
        FactoryGirl.create(:organization, aasm_state: 'all_done')
        Organization.visible_in_frontend.count.must_equal 2 # one approved and one done
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
    end
  end

  describe '#visible_in_frontend?' do
    it 'should return true for approved or all_done states' do
      orga.aasm_state = 'approved'
      orga.visible_in_frontend?.must_equal true
      orga.aasm_state = 'all_done'
      orga.visible_in_frontend?.must_equal true
    end

    it 'should return false for other states' do
      orga.aasm_state = 'initialized'
      orga.visible_in_frontend?.must_equal false
      orga.aasm_state = 'completed'
      orga.visible_in_frontend?.must_equal false
      orga.aasm_state = 'approval_process'
      orga.visible_in_frontend?.must_equal false
      orga.aasm_state = 'internal_feedback'
      orga.visible_in_frontend?.must_equal false
      orga.aasm_state = 'internal_feedback'
      orga.visible_in_frontend?.must_equal false
      orga.aasm_state = 'website_unreachable'
      orga.visible_in_frontend?.must_equal false
    end
  end

  describe '#in_section?' do
    it 'should return true for family when the section_filter is present' do
      orga.in_section?('family').must_equal true
    end
  end
end
