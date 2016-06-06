require_relative '../test_helper'

describe Offer do
  let(:offer) { Offer.new }
  let(:basicOffer) { offers(:basic) }

  subject { offer }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :name }
    it { subject.must_respond_to :description }
    it { subject.must_respond_to :old_next_steps }
    it { subject.must_respond_to :slug }
    it { subject.must_respond_to :created_at }
    it { subject.must_respond_to :updated_at }
    it { subject.must_respond_to :opening_specification }
    it { subject.must_respond_to :aasm_state }
    it { subject.must_respond_to :legal_information }
    it { subject.must_respond_to :age_from }
    it { subject.must_respond_to :age_to }
    it { subject.must_respond_to :exclusive_gender }
    it { subject.must_respond_to :target_audience }
    it { subject.must_respond_to :hide_contact_people }
    it { subject.must_respond_to :code_word }
    it { subject.must_respond_to :treatment_type }
    it { subject.must_respond_to :participant_structure }
    it { subject.must_respond_to :gender_first_part_of_stamp }
    it { subject.must_respond_to :gender_second_part_of_stamp }
    it { subject.must_respond_to :logic_version_id }
    it { subject.must_respond_to :split_base_id }
    it { subject.must_respond_to :all_inclusive }
  end

  describe 'validations' do
    describe 'always' do
      it { subject.must validate_presence_of :name }
      it { subject.must validate_presence_of :description }
      it { subject.must validate_presence_of :encounter }
      it { subject.must validate_length_of(:legal_information).is_at_most 400 }
      it { subject.must validate_presence_of :expires_at }
      it { subject.must validate_length_of(:code_word).is_at_most 140 }

      it 'should ensure that age_from fits age_to' do
        basicOffer.age_from = 9
        basicOffer.age_to = 1
        basicOffer.wont_be :valid?
        basicOffer.age_to = 10
        basicOffer.must_be :valid?
      end

      it 'should ensure a personal offer has a location' do
        basicOffer.encounter = 'personal'
        basicOffer.location_id = nil
        basicOffer.wont_be :valid?
        basicOffer.location_id = 1
        basicOffer.must_be :valid?
      end

      it 'should ensure a remote offer has no location but an area' do
        basicOffer.encounter = 'hotline'
        basicOffer.location_id = 1
        basicOffer.area_id = 1
        basicOffer.wont_be :valid?
        basicOffer.location_id = 1
        basicOffer.area_id = nil
        basicOffer.wont_be :valid?
        basicOffer.location_id = nil
        basicOffer.area_id = nil
        basicOffer.wont_be :valid?

        basicOffer.location_id = nil
        basicOffer.area_id = 1
        basicOffer.must_be :valid? # !
      end

      it 'should ensure locations and organizations fit together (personal)' do
        location = FactoryGirl.create(:location)
        basicOffer.location_id = location.id
        basicOffer.wont_be :valid?
        location.update_column :organization_id, organizations(:basic).id
        basicOffer.location.reload
        basicOffer.must_be :valid?
      end

      it 'should ensure all chosen organizations are approved' do
        basicOffer.organizations.update_all aasm_state: 'expired'
        basicOffer.reload.wont_be :valid?
        basicOffer.organizations.update_all aasm_state: 'approved'
        basicOffer.reload.must_be :valid?
      end

      it 'should ensure chosen contact people are SPoC or belong to orga' do
        cp = FactoryGirl.create :contact_person, spoc: false,
                                                 offers: [basicOffer]
        basicOffer.reload.wont_be :valid?
        cp.update_column :spoc, true
        basicOffer.reload.must_be :valid?
        cp.update_columns spoc: false, organization_id: organizations(:basic).id
        basicOffer.reload.must_be :valid?
      end

      it 'should ensure that no more than 10 next steps are chosen' do
        11.times do |i|
          basicOffer.next_steps << NextStep.create(text_de: i, text_en: i)
        end
        basicOffer.reload.wont_be :valid?
        NextStepsOffer.last.destroy!
        basicOffer.reload.must_be :valid?
      end

      it 'should validate expiration date' do
        subject.expires_at = Time.zone.now
        subject.valid?
        subject.errors.messages[:expires_at].must_include(
          I18n.t('shared.validations.later_date')
        )
      end

      it 'should validate age_from' do
        subject.must validate_numericality_of(:age_from).only_integer
          .is_greater_than_or_equal_to(0).is_less_than(99)
      end

      it 'should validate age_to' do
        subject.must validate_numericality_of(:age_to).only_integer
          .is_greater_than(0).is_less_than_or_equal_to(99)
      end

      it 'should validate that section filters of offer and categories fit' do
        category = FactoryGirl.create(:category)
        category.section_filters = [filters(:family)]
        basicOffer.categories = [category]
        basicOffer.section_filters = [filters(:refugees)]
        basicOffer.valid?.must_equal false

        basicOffer.section_filters = [filters(:family), filters(:refugees)]
        category.section_filters = [filters(:refugees)]
        basicOffer.valid?.must_equal false

        category.section_filters = [filters(:refugees), filters(:family)]
        basicOffer.valid?.must_equal true
        basicOffer.errors.messages[:categories].must_be :nil?

        basicOffer.section_filters = [filters(:refugees)]
        category2 = FactoryGirl.create(:category)
        category2.section_filters = [filters(:family)]
        basicOffer.categories << category2
        basicOffer.valid?.must_equal false

        basicOffer.section_filters = [filters(:family)]
        basicOffer.valid?.must_equal true

        category.section_filters = [filters(:refugees)]
        basicOffer.valid?.must_equal false

        basicOffer.section_filters = [filters(:family), filters(:refugees)]
        basicOffer.valid?.must_equal true
      end

      it 'should validate that split_base is assigned with version >= 8' do
        offer.logic_version = LogicVersion.create(name: 'chunky', version: 7)
        offer.split_base_id = nil
        offer.valid?
        offer.errors.messages[:split_base].must_be :nil?

        offer.logic_version = LogicVersion.create(name: 'bacon', version: 8)
        offer.valid?
        offer.errors.messages[:split_base].wont_be :nil?

        offer.split_base_id = 1
        offer.valid?
        offer.errors.messages[:split_base].must_be :nil?
      end

      # it 'should ensure chosen contact people belong to a chosen orga' do
      #   basicOffer.reload.wont_be :valid?
      #   basicOffer.reload.must_be :valid?
      # end
    end
  end

  describe 'observers' do
    describe 'after initialize' do
      it 'should get assigned the latest LogicVersion' do
        offer.logic_version_id.must_equal logic_versions(:basic).id
        new_logic = LogicVersion.create(name: 'Foo', version: 200)
        OfferObserver.send(:new).after_initialize(offer)
        offer.logic_version_id.must_equal new_logic.id
      end
    end
  end

  describe '::Base' do
    describe 'associations' do
      it { subject.must belong_to :location }
      it { subject.must belong_to :area }
      it { subject.must belong_to :solution_category }
      it { subject.must belong_to :logic_version }
      it { subject.must have_many :organization_offers }
      it { subject.must have_many(:organizations).through :organization_offers }
      it { subject.must have_and_belong_to_many :categories }
      it { subject.must have_and_belong_to_many :filters }
      it { subject.must have_and_belong_to_many :section_filters }
      it { subject.must have_and_belong_to_many :language_filters }
      it { subject.must have_and_belong_to_many :target_audience_filters }
      it { subject.must have_and_belong_to_many :trait_filters }
      it { subject.must have_and_belong_to_many :openings }
      it { subject.must have_many :hyperlinks }
      it { subject.must have_many :websites }
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
        tags = offers(:basic)._tags(:de)
        tags.must_include 'sub1.1'
        tags.must_include 'sub1.2'
        tags.must_include 'main1'
        tags.count('main1').must_equal 1
        tags.wont_include 'main2'
      end

      it 'should return translated categories with ancestors when non-german' do
        Category.find(1).update_column :name_en, 'enmain1'
        Category.find(3).update_column :name_en, 'ensub1.1'

        offers(:basic).categories << categories(:sub1)
        tags = offers(:basic)._tags(:en)
        tags.must_include 'ensub1.1'
        tags.must_include 'enmain1'
      end
    end

    describe '#category_names' do
      it 'should refer to tags to gather category information' do
        offer = offers(:basic)
        offer.expect_chain(:_tags, :join).once
        offer.category_names
      end

      it 'should concat category names' do
        offer = offers(:basic)
        offer.categories << categories(:sub1)
        offer.category_names.must_equal 'main1 sub1.1'
      end
    end

    describe '#organization_count' do
      it 'should return 1 if there is only one' do
        offers(:basic).organization_count.must_equal(1)
      end

      it 'should return 2 if there are two organizations' do
        offers(:basic).organizations << FactoryGirl.create(:organization)
        offers(:basic).organization_count.must_equal(2)
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

    describe '#target_audience_filters?' do
      it 'should behave correctly in family section' do
        offer = offers(:basic)
        offer.section_filters = [filters(:family)]
        offer.expects(:fail_validation).never
        offer.send :validate_associated_fields
        offer.target_audience_filters = []
        offer.expects(:fail_validation).with :target_audience_filters,
                                             'needs_target_audience_filters'
        offer.send :validate_associated_fields
      end

      it 'should behave correctly in refugees section' do
        offer = offers(:basic)
        offer.section_filters = [filters(:refugees)]
        offer.expects(:fail_validation).never
        offer.send :validate_associated_fields
        offer.target_audience_filters = []
        offer.send :validate_associated_fields
      end
    end

    describe '#in_section?' do
      it 'should correctly reply to in_section? call' do
        off = offers(:basic)
        off.in_section?('family').must_equal true
        off.in_section?('refugees').must_equal false
      end
    end

    describe '::in_section?' do
      it 'should correctly retrieve offers with in_section scope' do
        Offer.in_section('family').must_equal [offers(:basic)]
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

    describe 'translation' do
      it 'should get translated name, description, and old_next_steps' do
        Offer.any_instance.stubs(:generate_translations!)
        offer = FactoryGirl.create :offer
        offer.translations <<
          FactoryGirl.create(:offer_translation, locale: :de, name: 'de name',
                                                 description: 'de desc',
                                                 old_next_steps: 'de next')
        offer.translations <<
          FactoryGirl.create(:offer_translation, locale: :en, name: 'en name',
                                                 description: 'en desc',
                                                 old_next_steps: 'en next')
        old_locale = I18n.locale

        I18n.locale = :de
        offer.name.must_equal 'de name'
        offer.description.must_equal 'de desc'
        offer.old_next_steps.must_equal 'de next'

        I18n.locale = :en
        offer = Offer.find(offer.id) # clear memoization
        offer.name.must_equal 'en name'
        offer.description.must_equal 'en desc'
        offer.old_next_steps.must_equal 'en next'

        I18n.locale = old_locale
      end

      it 'should always get de translation, others on completion and change' do
        # Setup
        new_offer = FactoryGirl.create(:offer)
        new_offer.translations.count.must_equal 1
        new_offer.translations.first.locale.must_equal 'de'
        new_offer.aasm_state.must_equal 'initialized'

        # Changing things on an initialized offer doesn't change translations
        new_offer.reload.name_ar.must_equal nil
        new_offer.name = 'changing name, wont update translation'
        new_offer.save!
        new_offer.translations.count.must_equal 1
        new_offer.reload.name_ar.must_equal nil

        # Completion generates all translations initially
        new_offer.complete!
        new_offer.translations.count.must_equal I18n.available_locales.count

        # Now changes to the model change the corresponding translated fields

        EasyTranslate.translated_with 'CHANGED' do
          new_offer.reload.name_ar.must_equal 'GET READY FOR CANADA'
          new_offer.description_ar.must_equal 'GET READY FOR CANADA'
          new_offer.name = 'changing name, should update translation'
          new_offer.save!
          new_offer.reload.name_ar.must_equal 'CHANGED'
          new_offer.description_ar.must_equal 'GET READY FOR CANADA'
        end
      end

      it 'should update an existing translation only when the field changed' do
        # Setup
        new_offer = FactoryGirl.create(:offer)
        new_offer.complete!
        new_offer.translations.count.must_equal I18n.available_locales.count

        # Now changes to the model change the corresponding translated fields
        EasyTranslate.translated_with 'CHANGED' do
          new_offer.reload.name_ar.must_equal 'GET READY FOR CANADA'
          new_offer.description_ar.must_equal 'GET READY FOR CANADA'
          # changing untranslated field => translations must stay the same
          new_offer.age_from = 0
          new_offer.save!
          new_offer.reload.name_ar.must_equal 'GET READY FOR CANADA'
          new_offer.reload.description_ar.must_equal 'GET READY FOR CANADA'
          new_offer.name = 'changing name, should update translation'
          new_offer.save!
          new_offer.reload.name_ar.must_equal 'CHANGED'
          new_offer.reload.description_ar.must_equal 'GET READY FOR CANADA'
        end
      end
    end

    describe 'State Machine' do
      describe '#different_actor?' do
        it 'should return true when created_by differs from current_actor' do
          offer.created_by = 99
          offer.send(:different_actor?).must_equal true
        end

        it 'should return false when created_by is the same as current_actor' do
          offer.created_by = offer.current_actor
          offer.send(:different_actor?).must_equal false
        end

        it 'should return falsy when created_by is nil' do
          offer.send(:different_actor?).must_equal nil
        end

        it 'should return false when current_actor is nil' do
          offer.created_by = 1
          offer.stubs(:current_actor).returns(nil)
          offer.send(:different_actor?).must_equal nil
        end
      end

      describe '#LogicVersion' do
        it 'should have the latest LogicVersion after :complete and :approve' do
          offer.created_by = 99
          offer.aasm_state = 'initialized'
          offer.logic_version_id.must_equal logic_versions(:basic).id
          new_logic1 = LogicVersion.create(name: 'Foo', version: 200)
          offer.send(:complete)
          offer.logic_version_id.must_equal new_logic1.id
          new_logic2 = LogicVersion.create(name: 'Bar', version: 201)
          offer.send(:approve)
          offer.logic_version_id.must_equal new_logic2.id
        end
      end
    end

    describe '#opening_details?' do
      it 'should return false when there are no openings / opening specs' do
        offer.opening_details?.must_equal false
      end

      it 'should return true when there are openings and opening specs' do
        offer.openings = Opening.limit(1)
        offer.opening_specification = 'chunky bacon'
        offer.opening_details?.must_equal true
      end
    end

    describe 'search' do
      it 'should correctly return geolocation hash for algolia' do
        loc = FactoryGirl.create(:location)
        basicOffer.location_id = loc.id
        basicOffer._geoloc.must_equal('lat' => 10, 'lng' => 20)
      end

      it 'should correctly return keywords_string' do
        basicOffer.keywords << keywords(:basic)
        basicOffer.keyword_string.must_equal 'test, synonym'
      end

      it 'should correctly return age_filters' do
        basicOffer._age_filters.must_equal((0..17).to_a)
      end

      it 'should correctly return organization_names' do
        basicOffer.organization_names.must_equal 'foobar'
      end

      it 'should correctly return visible boolean' do
        loc = FactoryGirl.create(:location)
        basicOffer.location_id = loc.id

        basicOffer.location.visible = false
        basicOffer.location_visible.must_equal false

        basicOffer.location.visible = true
        basicOffer.location_visible.must_equal true

        basicOffer.location = nil
        basicOffer.location_visible.must_equal false
      end

      it 'should correctly return next_steps for german locale' do
        old_locale = I18n.locale
        I18n.locale = :en
        basicOffer.next_steps <<
          NextStep.create(text_de: 'fu.', text_en: 'foo.')
        basicOffer.next_steps <<
          NextStep.create(text_de: 'kneipe.', text_en: 'bar.')
        basicOffer.next_steps_for_current_locale.must_equal 'foo. bar.'
        I18n.locale = old_locale
      end

      it 'should correctly respond to _next_steps' do
        basicOffer.next_steps = []
        basicOffer.expects(:send).with("old_next_steps_#{I18n.locale}")
        basicOffer._next_steps I18n.locale

        basicOffer.next_steps <<
          NextStep.create(text_de: 'fu.', text_en: 'foo.')
        basicOffer.expects(:send).with("old_next_steps_#{I18n.locale}").never
        basicOffer._next_steps(I18n.locale).must_equal 'fu.'
      end

      it 'should return a translation lang for automated translations' do
        OfferTranslation.create!(
          offer_id: 1, name: 'eng', description: 'eng', locale: :en,
          source: 'GoogleTranslate')
        basicOffer.lang(:en).must_equal 'en-x-mtfrom-de'
      end

      it 'should return a locale lang for manual translations' do
        OfferTranslation.create!(
          offer_id: 1, name: 'eng', description: 'eng', locale: :en,
          source: 'researcher')
        basicOffer.lang(:en).must_equal 'en'
      end

      it 'should correctly return _exclusive_gender_filters' do
        basicOffer.exclusive_gender = 'boys_only'
        basicOffer._exclusive_gender_filters.must_equal(['boys_only'])
      end

      it 'should correctly return target_audience_filters' do
        basicOffer._target_audience_filters.must_equal(['family_children'])
      end

      it 'should correctly return language_filters' do
        basicOffer._language_filters.must_equal(['deu'])
      end
    end

    describe 'stamp' do
      it 'should correctly respond to general _stamp_SECTION call' do
        basicOffer._stamp_family(:de).must_equal 'für Kinder und Jugendliche'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge'
      end

      it 'should correctly respond some general english _stamp_ calls' do
        basicOffer._stamp_family(:en).must_equal 'for children and adolescents'
        basicOffer._stamp_refugees(:en).must_equal 'for refugees'
      end

      it 'should respond correctly for invisible age' do
        basicOffer._stamp_family(:de).must_equal 'für Kinder und Jugendliche'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge'
      end

      it 'should respond correctly for several visible age combinations' do
        basicOffer.age_visible = true
        basicOffer.age_from = 0
        basicOffer.age_to = 2
        basicOffer._stamp_family(:de).must_equal 'für Kinder (bis 2 Jahre)'

        basicOffer.age_from = 2
        basicOffer._stamp_family(:de).must_equal 'für Kinder (2 Jahre)'

        basicOffer.age_to = 18
        basicOffer._stamp_family(:de).must_equal 'für Kinder und Jugendliche (ab 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (2 - 18 Jahre)'

        basicOffer.age_to = 99
        basicOffer._stamp_family(:de).must_equal 'für Kinder und Jugendliche (ab 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (ab 2 Jahre)'

        basicOffer.age_visible = false
        basicOffer._stamp_family(:de).must_equal 'für Kinder und Jugendliche'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge'

        basicOffer.age_visible = true
        basicOffer.target_audience_filters =
          [TargetAudienceFilter.find_by(identifier: 'family_everyone')]
        basicOffer._stamp_family(:de).must_equal 'für alle'
      end

      it 'should behave correctly for family_children target_audience' do
        basicOffer.age_visible = true
        basicOffer.age_from = 1
        basicOffer.age_to = 2
        basicOffer._stamp_family(:de).must_equal 'für Kinder (1 - 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (1 - 2 Jahre)'

        basicOffer.age_from = 15
        basicOffer.age_to = 16
        basicOffer._stamp_family(:de).must_equal 'für Jugendliche (15 - 16 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (15 - 16 Jahre)'

        basicOffer.age_from = 7
        basicOffer.age_to = 16
        basicOffer._stamp_family(:de).must_equal 'für Kinder und Jugendliche (7 - 16 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (7 - 16 Jahre)'

        basicOffer.gender_first_part_of_stamp = 'male'
        basicOffer._stamp_family(:de).must_equal 'für Jungen (7 - 16 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (7 - 16 Jahre)'

        basicOffer.gender_first_part_of_stamp = 'female'
        basicOffer._stamp_family(:de).must_equal 'für Mädchen (7 - 16 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (7 - 16 Jahre)'
      end

      it 'should behave correctly for family_parents target_audience' do
        basicOffer.target_audience_filters =
          [TargetAudienceFilter.find_by(identifier: 'family_parents')]
        basicOffer.age_visible = true
        basicOffer.age_from = 1
        basicOffer.age_to = 2
        basicOffer._stamp_family(:de).must_equal 'für Eltern (1 - 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (1 - 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'neutral'
        basicOffer._stamp_family(:de).must_equal 'für Eltern (Alter des Kindes: 1 - 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (1 - 2 Jahre)'

        basicOffer.gender_first_part_of_stamp = 'female'
        basicOffer._stamp_family(:de).must_equal 'für Mütter (Alter des Kindes: 1 - 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (1 - 2 Jahre)'

        basicOffer.gender_first_part_of_stamp = 'male'
        basicOffer._stamp_family(:de).must_equal 'für Väter (Alter des Kindes: 1 - 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (1 - 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'male'
        basicOffer._stamp_family(:de).must_equal 'für Väter von Söhnen (1 - 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (1 - 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'female'
        basicOffer._stamp_family(:de).must_equal 'für Väter von Töchtern (1 - 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (1 - 2 Jahre)'

        basicOffer.gender_first_part_of_stamp = ''
        basicOffer._stamp_family(:de).must_equal 'für Eltern von Töchtern (1 - 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (1 - 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'male'
        basicOffer._stamp_family(:de).must_equal 'für Eltern von Söhnen (1 - 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (1 - 2 Jahre)'

        basicOffer.gender_first_part_of_stamp = 'female'
        basicOffer._stamp_family(:de).must_equal 'für Mütter von Söhnen (1 - 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (1 - 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'female'
        basicOffer._stamp_family(:de).must_equal 'für Mütter von Töchtern (1 - 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (1 - 2 Jahre)'
      end

      it 'should behave correctly for family_nuclear_family target_audience' do
        basicOffer.target_audience_filters =
          [TargetAudienceFilter.find_by(identifier: 'family_nuclear_family')]
        basicOffer._stamp_family(:de).must_equal 'für Familien'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge'

        basicOffer.gender_second_part_of_stamp = 'neutral'
        basicOffer.age_from = 0
        basicOffer.age_to = 1
        basicOffer._stamp_family(:de).must_equal 'für Familien und ihre Babys'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge'

        basicOffer.age_visible = true
        basicOffer.age_from = 1
        basicOffer.age_to = 2
        basicOffer._stamp_family(:de).must_equal 'für Familien und ihre Kinder (1 - 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (1 - 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = ''
        basicOffer._stamp_family(:de).must_equal 'für Familien'

        basicOffer.gender_second_part_of_stamp = 'male'
        basicOffer._stamp_family(:de).must_equal 'für Familien und ihre Söhne (1 - 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (1 - 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'female'
        basicOffer._stamp_family(:de).must_equal 'für Familien und ihre Töchter (1 - 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (1 - 2 Jahre)'

        basicOffer.gender_first_part_of_stamp = 'female'
        basicOffer.gender_second_part_of_stamp = 'neutral'
        basicOffer._stamp_family(:de).must_equal 'für Mütter und ihre Kinder (1 - 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (1 - 2 Jahre)'

        basicOffer.gender_first_part_of_stamp = 'male'
        basicOffer._stamp_family(:de).must_equal 'für Väter und ihre Kinder (1 - 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (1 - 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'male'
        basicOffer._stamp_family(:de).must_equal 'für Väter und ihre Söhne (1 - 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (1 - 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'female'
        basicOffer._stamp_family(:de).must_equal 'für Väter und ihre Töchter (1 - 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (1 - 2 Jahre)'

        basicOffer.gender_first_part_of_stamp = 'female'
        basicOffer._stamp_family(:de).must_equal 'für Mütter und ihre Töchter (1 - 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (1 - 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = nil
        basicOffer._stamp_family(:de).must_equal 'für Mütter und ihre Kinder (1 - 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (1 - 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'male'
        basicOffer._stamp_family(:de).must_equal 'für Mütter und ihre Söhne (1 - 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (1 - 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'neutral'
        basicOffer._stamp_family(:de).must_equal 'für Mütter und ihre Kinder (1 - 2 Jahre)'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge (1 - 2 Jahre)'
      end

      it 'should behave correctly for family_parents_to_be target_audience' do
        basicOffer.target_audience_filters =
          [TargetAudienceFilter.find_by(identifier: 'family_parents_to_be')]
        basicOffer._stamp_family(:de).must_equal 'für werdende Eltern'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge'

        basicOffer.gender_second_part_of_stamp = 'neutral'
        basicOffer._stamp_family(:de).must_equal 'für werdende Eltern und ihre Kinder'

        basicOffer.gender_second_part_of_stamp = 'male'
        basicOffer._stamp_family(:de).must_equal 'für werdende Eltern und ihre Söhne'

        basicOffer.gender_second_part_of_stamp = 'female'
        basicOffer._stamp_family(:de).must_equal 'für werdende Eltern und ihre Töchter'

        basicOffer.gender_first_part_of_stamp = 'female'
        basicOffer.gender_second_part_of_stamp = ''
        basicOffer._stamp_family(:de).must_equal 'für Schwangere'

        basicOffer.gender_first_part_of_stamp = 'male'
        basicOffer._stamp_family(:de).must_equal 'für werdende Väter'

        basicOffer.gender_second_part_of_stamp = 'neutral'
        basicOffer._stamp_family(:de).must_equal 'für werdende Väter und ihre Kinder'

        basicOffer.gender_second_part_of_stamp = 'male'
        basicOffer._stamp_family(:de).must_equal 'für werdende Väter und ihre Söhne'

        basicOffer.gender_second_part_of_stamp = 'female'
        basicOffer._stamp_family(:de).must_equal 'für werdende Väter und ihre Töchter'

        basicOffer.gender_first_part_of_stamp = 'female'
        basicOffer._stamp_family(:de).must_equal 'für Schwangere und ihre Töchter'

        basicOffer.gender_second_part_of_stamp = 'male'
        basicOffer._stamp_family(:de).must_equal 'für Schwangere und ihre Söhne'

        basicOffer.gender_second_part_of_stamp = 'neutral'
        basicOffer._stamp_family(:de).must_equal 'für Schwangere und ihre Kinder'
      end

      it 'should behave correctly for the remaining family target audiences' do
        basicOffer.target_audience_filters =
          [TargetAudienceFilter.find_by(identifier: 'family_acquaintances')]
        basicOffer._stamp_family(:de).must_equal 'für Bekannte und Verwandte'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge'

        basicOffer.target_audience_filters =
          [TargetAudienceFilter.find_by(identifier: 'family_everyone')]
        basicOffer._stamp_family(:de).must_equal 'für alle'
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge'
      end

      it 'should behave correctly for refugees target audiences' do
        basicOffer.target_audience_filters =
          [TargetAudienceFilter.create(name: 'ref_1', identifier: 'refugees_children')]
        basicOffer._stamp_refugees(:de).must_equal 'für geflüchtete Kinder'
        basicOffer._stamp_family(:de).must_equal ''

        basicOffer.target_audience_filters =
          [TargetAudienceFilter.create(name: 'ref_2', identifier: 'refugees_adolescents')]
        basicOffer._stamp_refugees(:de).must_equal 'für geflüchtete Jugendliche'

        basicOffer.target_audience_filters =
          [TargetAudienceFilter.create(name: 'ref_3', identifier: 'refugees_children_and_adolescents')]
        basicOffer._stamp_refugees(:de).must_equal 'für geflüchtete Kinder und Jugendliche'

        basicOffer.target_audience_filters =
          [TargetAudienceFilter.create(name: 'ref_4', identifier: 'refugees_umf')]
        basicOffer._stamp_refugees(:de).must_equal 'für unbegleitete minderjährige Flüchtlinge'

        basicOffer.target_audience_filters =
          [TargetAudienceFilter.create(name: 'ref_5', identifier: 'refugees_ujf')]
        basicOffer._stamp_refugees(:de).must_equal 'für unbegleitete junge Flüchtlinge'

        basicOffer.age_visible = true
        basicOffer.age_from = 1
        basicOffer.age_to = 2
        basicOffer.target_audience_filters =
          [TargetAudienceFilter.create(name: 'ref_6', identifier: 'refugees_families')]
        basicOffer._stamp_refugees(:de).must_equal 'für geflüchtete Familien'

        basicOffer.age_visible = false
        basicOffer.target_audience_filters =
          [TargetAudienceFilter.create(name: 'ref_7', identifier: 'refugees_pre_asylum_procedure')]
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge vor dem Asylantrag'

        basicOffer.target_audience_filters =
          [TargetAudienceFilter.create(name: 'ref_8', identifier: 'refugees_asylum_procedure')]
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge im Asylverfahren'

        basicOffer.target_audience_filters =
          [TargetAudienceFilter.create(name: 'ref_9', identifier: 'refugees_deportation_decision')]
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge mit Abschiebebescheid'

        basicOffer.target_audience_filters =
          [TargetAudienceFilter.create(name: 'ref_10', identifier: 'refugees_toleration_decision')]
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge mit Duldung'

        basicOffer.target_audience_filters =
          [TargetAudienceFilter.create(name: 'ref_11', identifier: 'refugees_residence_permit')]
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge mit Aufenthaltserlaubnis'

        basicOffer.target_audience_filters =
          [TargetAudienceFilter.create(name: 'ref_13', identifier: 'refugees_parents')]
        basicOffer._stamp_refugees(:de).must_equal 'für geflüchtete Eltern'

        basicOffer.target_audience_filters =
          [TargetAudienceFilter.create(name: 'ref_14', identifier: 'refugees_general')]
        basicOffer._stamp_refugees(:de).must_equal 'für Flüchtlinge'
      end
    end
  end
end
