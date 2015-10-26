require_relative '../test_helper'

describe Offer do
  let(:offer) { Offer.new }

  subject { offer }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :name }
    it { subject.must_respond_to :description }
    it { subject.must_respond_to :next_steps }
    it { subject.must_respond_to :slug }
    it { subject.must_respond_to :created_at }
    it { subject.must_respond_to :updated_at }
    it { subject.must_respond_to :opening_specification }
    it { subject.must_respond_to :comment }
    it { subject.must_respond_to :aasm_state }
    it { subject.must_respond_to :legal_information }
    it { subject.must_respond_to :age_from }
    it { subject.must_respond_to :age_to }
    it { subject.must_respond_to :exclusive_gender }
    it { subject.must_respond_to :target_audience }
  end

  describe 'validations' do
    describe 'always' do
      it { subject.must validate_presence_of :name }
      it { subject.must validate_length_of(:name).is_at_most 80 }
      it { subject.must validate_presence_of :description }
      it { subject.must validate_length_of(:description).is_at_most 450 }
      it { subject.must validate_presence_of :next_steps }
      it { subject.must validate_presence_of :encounter }
      it { subject.must validate_length_of(:next_steps).is_at_most 500 }
      it { subject.must validate_length_of(:comment).is_at_most 800 }
      it { subject.must validate_length_of(:legal_information).is_at_most 400 }
      it { subject.must validate_presence_of :expires_at }
      it do
        subject.must validate_length_of(:opening_specification).is_at_most 400
      end
    end

    describe 'when in family section' do
      before { subject.section_filters = [filters(:family)] }

      it do
        subject.must validate_numericality_of(:age_from).only_integer
          .is_greater_than_or_equal_to(0).is_less_than_or_equal_to(17)
      end
      it do
        subject.must validate_numericality_of(:age_to).only_integer
          .is_greater_than(0).is_less_than_or_equal_to(17)
      end
    end

    describe 'when not in family section' do
      before { subject.section_filters = [] }

      it do
        subject.must validate_numericality_of(:age_from).only_integer
          .is_greater_than_or_equal_to(0) # no less_than_or_equal_to
      end
      it do
        subject.must validate_numericality_of(:age_to).only_integer
          .is_greater_than(0) # no less_than_or_equal_to
      end
    end

    describe 'custom' do
      it 'should validate expiration date' do
        subject.expires_at = Time.zone.now
        subject.valid?
        subject.errors.messages[:expires_at].must_include(
          I18n.t('shared.validations.later_date')
        )
      end
    end
  end

  describe '::Base' do
    describe 'associations' do
      it { subject.must belong_to :location }
      it { subject.must have_many :organization_offers }
      it { subject.must have_many(:organizations).through :organization_offers }
      it { subject.must have_and_belong_to_many :categories }
      it { subject.must have_and_belong_to_many :filters }
      it { subject.must have_and_belong_to_many :section_filters }
      it { subject.must have_and_belong_to_many :language_filters }
      it { subject.must have_and_belong_to_many :target_audience_filters }
      it { subject.must have_and_belong_to_many :openings }
      it { subject.must have_many :hyperlinks }
      it { subject.must have_many :websites }

      it { subject.must have_many :offer_mailings }
      it { subject.must have_many(:informed_emails).through :offer_mailings }
    end
  end

  describe 'methods' do
    describe '#creator' do
      it 'should return anonymous by default' do
        offer.creator.must_equal 'anonymous'
      end

      it 'should return users name if there is a version' do
        offer = FactoryGirl.create :offer, :with_creator
        offer.creator.must_equal User.find(offer.created_by).name
      end
    end

    describe '#_tags' do
      it 'should return unique categories with ancestors of an offer' do
        offers(:basic).categories << categories(:sub1)
        offers(:basic).categories << categories(:sub2)
        tags = offers(:basic)._tags
        tags.must_include 'sub1.1'
        tags.must_include 'sub1.2'
        tags.must_include 'main1'
        tags.count('main1').must_equal 1
        tags.wont_include 'main2'
      end
    end

    describe '#organization_display_name' do
      it "should return the first organization's name if there is only one" do
        offers(:basic).organization_display_name.must_equal(
          organizations(:basic).name
        )
      end

      it 'should return a string when there are multiple organizations' do
        offers(:basic).organizations << FactoryGirl.create(:organization)
        offers(:basic).organization_display_name.must_equal(
          I18n.t('offer.organization_display_name.cooperation')
        )
      end
    end

    describe '#personal_indexable?' do
      it 'should return true when personal and approved' do
        offer.aasm_state = 'approved'
        offer.stubs(:personal?).returns true
        offer.personal_indexable?.must_equal true
      end

      it 'should return false when not personal and approved' do
        offer.aasm_state = 'approved'
        offer.stubs(:personal?).returns false
        offer.personal_indexable?.must_equal false
      end

      it 'should return false when not approved' do
        offer.aasm_state = 'completed'
        offer.expects(:personal?).never
        offer.personal_indexable?.must_equal false
      end
    end

    describe '#remote_indexable?' do
      it 'should return true when not personal and approved' do
        offer.aasm_state = 'approved'
        offer.stubs(:personal?).returns false
        offer.remote_indexable?.must_equal true
      end

      it 'should return false when personal and approved' do
        offer.aasm_state = 'approved'
        offer.stubs(:personal?).returns true
        offer.remote_indexable?.must_equal false
      end

      it 'should return false when not approved' do
        offer.aasm_state = 'completed'
        offer.expects(:personal?).never
        offer.remote_indexable?.must_equal false
      end
    end

    describe '#section_filters_must_match_categories_section_filters' do
      it 'should fail when single filter does not match' do
        offer = offers(:basic)
        category = categories(:main1)
        offer.section_filters << filters(:refugees)
        offer.categories << category
        offer.expects(:fail_validation).with :section_filters,
                                             'section_filter_not_found_in_cate'\
                                             'gory',
                                             world: 'Refugees',
                                             category: category.name
        offer.section_filters_must_match_categories_section_filters
      end

      it 'should fail when multiple filters do not match' do
        off = offers(:basic)
        category = categories(:main2)
        off.section_filters = [filters(:refugees), filters(:family)]
        off.categories << category
        off.expects(:fail_validation).with :section_filters,
                                           'section_filter_not_found_in_cate'\
                                           'gory',
                                           world: 'Family',
                                           category: category.name
        off.section_filters_must_match_categories_section_filters
      end

      it 'should fail only on mismatching categories' do
        off = offers(:basic)
        category = categories(:main2)
        off.section_filters = [filters(:refugees), filters(:family)]
        off.categories << category
        off.categories << categories(:main3)
        off.expects(:fail_validation).with :section_filters,
                                           'section_filter_not_found_in_cate'\
                                           'gory',
                                           world: 'Family',
                                           category: category.name
        off.section_filters_must_match_categories_section_filters
      end

      it 'should succeed when single family world matches' do
        off = offers(:basic)
        off.section_filters = [filters(:family)]
        off.categories << categories(:main1)
        off.expects(:fail_validation).never
        off.section_filters_must_match_categories_section_filters
      end

      it 'should succeed when single refugee world matches on multiple' do
        off = offers(:basic)
        off.section_filters = [filters(:refugees)]
        off.categories << categories(:main3)
        off.expects(:fail_validation).never
        off.section_filters_must_match_categories_section_filters
      end

      it 'should succeed when multiple worlds match' do
        off = offers(:basic)
        off.section_filters = [filters(:refugees), filters(:family)]
        off.categories << categories(:main3)
        off.expects(:fail_validation).never
        off.section_filters_must_match_categories_section_filters
      end
    end

    describe '::per_env_index' do
      it 'should return Offer_envname for a non-development env' do
        Offer.per_env_index.must_equal 'Offer_test'
      end

      it 'should attach the user name to the development env' do
        Rails.stubs(:env)
          .returns ActiveSupport::StringInquirer.new('development')
        ENV.stubs(:[]).returns 'foobar'
        Offer.per_env_index.must_equal 'Offer_development_foobar'
      end
    end
  end
end
