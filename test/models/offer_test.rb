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
    it { subject.must_respond_to :starts_at }
    it { subject.must_respond_to :completed_at }
    it { subject.must_respond_to :completed_by }
    it { subject.must_respond_to :residency_status }
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

      it 'should validate start date' do
        basicOffer.expires_at = Time.zone.now + 1.day
        basicOffer.valid?.must_equal true

        basicOffer.starts_at = Time.zone.now + 2.day
        basicOffer.valid?.must_equal false

        basicOffer.starts_at = Time.zone.now
        basicOffer.valid?.must_equal true
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

      it 'should validate that split_base is assigned with version >= 7' do
        offer.logic_version = LogicVersion.create(name: 'chunky', version: 6)
        offer.split_base_id = nil
        offer.valid?
        offer.errors.messages[:split_base].must_be :nil?

        offer.logic_version = LogicVersion.create(name: 'bacon', version: 7)
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

      it 'should return true when personal and expired' do
        offer.aasm_state = 'expired'
        offer.stubs(:personal?).returns true
        offer.personal_indexable?.must_equal true
      end

      it 'should return false when not personal and approved' do
        offer.aasm_state = 'approved'
        offer.stubs(:personal?).returns false
        offer.personal_indexable?.must_equal false
      end

      it 'should return true when not personal and expired' do
        offer.aasm_state = 'expired'
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

      it 'should return true when not personal and expired' do
        offer.aasm_state = 'expired'
        offer.stubs(:personal?).returns false
        offer.remote_indexable?.must_equal true
      end

      it 'should return false when personal and approved' do
        offer.aasm_state = 'approved'
        offer.stubs(:personal?).returns true
        offer.remote_indexable?.must_equal false
      end

      it 'should return false when personal and expired' do
        offer.aasm_state = 'expired'
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
        offer.expects(:fail_validation).with :target_audience_filters,
                                             'needs_target_audience_filters'
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

    describe '::personal_index_name' do
      it 'should respond with corrent name for non-development env' do
        Offer.personal_index_name('de').must_equal 'Offer_test_personal_de'
      end

      it 'should attach the user name to the development env' do
        Rails.stubs(:env)
             .returns ActiveSupport::StringInquirer.new('development')
        ENV.stubs(:[]).returns 'foobar'
        Offer.personal_index_name('de')
             .must_equal 'Offer_development_foobar_personal_de'
      end
    end

    describe '::remote_index_name' do
      it 'should respond with corrent name for non-development env' do
        Offer.remote_index_name('de').must_equal 'Offer_test_remote_de'
      end

      it 'should attach the user name to the development env' do
        Rails.stubs(:env)
             .returns ActiveSupport::StringInquirer.new('development')
        ENV.stubs(:[]).returns 'foobar'
        Offer.remote_index_name('de')
             .must_equal 'Offer_development_foobar_remote_de'
      end
    end

    # Testing only BaseTranslation Logic here
    describe 'translation' do
      let(:translation) { OfferTranslation.new }
      subject { translation }

      describe 'methods' do
        describe '#automated' do
          it 'must be true for source=GoogleTranslate' do
            subject.source = 'GoogleTranslate'
            subject.automated?.must_equal true
          end
          it 'must be false for other source' do
            subject.source = 'researcher'
            subject.automated?.must_equal false
          end
        end

        describe '#manually_editable' do
          it 'must be true for every manually translated locale' do
            BaseTranslation::MANUALLY_TRANSLATED_LOCALES.map do |l|
              subject.locale = l.to_s
              subject.manually_editable?.must_equal true
            end
          end
          it 'must be false for any other available_locale' do
            (I18n.available_locales.map(&:to_s) - BaseTranslation::MANUALLY_TRANSLATED_LOCALES)
              .map do |l|
              subject.locale = l
              subject.manually_editable?.must_equal false
            end
          end
        end

        describe '#manually_edited' do
          it 'must be false for a new record' do
            subject.manually_edited?.must_equal false
          end

          it 'must be true for manually edited record' do
            offer = FactoryGirl.create :offer
            translation =
              FactoryGirl.create(:offer_translation, locale: :en,
                                                     name: 'en name',
                                                     description: 'en desc',
                                                     old_next_steps: 'en next')
            offer.translations << translation
            translation.description = 'en new desc'
            translation.source = 'researcher'
            translation.save
            translation.manually_edited?.must_equal true
          end
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

    describe '#visible_in_frontend?' do
      it 'should return true for approved or expired states' do
        basicOffer.aasm_state = 'approved'
        basicOffer.visible_in_frontend?.must_equal true
        basicOffer.aasm_state = 'expired'
        basicOffer.visible_in_frontend?.must_equal true
      end

      it 'should return false for other states' do
        basicOffer.aasm_state = 'initialized'
        basicOffer.visible_in_frontend?.must_equal false
        basicOffer.aasm_state = 'completed'
        basicOffer.visible_in_frontend?.must_equal false
        basicOffer.aasm_state = 'approval_process'
        basicOffer.visible_in_frontend?.must_equal false
        basicOffer.aasm_state = 'internal_feedback'
        basicOffer.visible_in_frontend?.must_equal false
        basicOffer.aasm_state = 'internal_feedback'
        basicOffer.visible_in_frontend?.must_equal false
        basicOffer.aasm_state = 'website_unreachable'
        basicOffer.visible_in_frontend?.must_equal false
        basicOffer.aasm_state = 'organization_deactivated'
        basicOffer.visible_in_frontend?.must_equal false
        basicOffer.aasm_state = 'under_construction_pre'
        basicOffer.visible_in_frontend?.must_equal false
        basicOffer.aasm_state = 'under_construction_post'
        basicOffer.visible_in_frontend?.must_equal false
      end
    end

    describe 'generated OfferStamp' do
      it 'should correctly respond to general _stamp_SECTION call' do
        basicOffer.target_audience_filters =
          [TargetAudienceFilter.find_by(identifier: 'family_children'),
           TargetAudienceFilter.create(name: 'Flüchtlinge', identifier: 'refugees_general')]
        basicOffer.stamp_family(:de).must_equal 'für Kinder und Jugendliche'
        basicOffer.stamp_refugees(:de).must_equal 'für Flüchtlinge'
      end

      it 'should correctly respond some general english _stamp_ calls' do
        basicOffer.target_audience_filters =
          [TargetAudienceFilter.find_by(identifier: 'family_children'),
           TargetAudienceFilter.create(name: 'Flüchtlinge', identifier: 'refugees_general')]
        basicOffer.stamp_family(:en).must_equal 'for children and adolescents'
        basicOffer.stamp_refugees(:en).must_equal 'for refugees'
      end

      it 'should respond correctly for invisible age' do
        basicOffer.target_audience_filters =
          [TargetAudienceFilter.find_by(identifier: 'family_children'),
           TargetAudienceFilter.create(name: 'Flüchtlinge', identifier: 'refugees_general')]
        basicOffer.stamp_family(:de).must_equal 'für Kinder und Jugendliche'
        basicOffer.stamp_refugees(:de).must_equal 'für Flüchtlinge'
      end

      it 'should respond correctly for several visible age combinations' do
        basicOffer.age_visible = true
        basicOffer.age_from = 0
        basicOffer.age_to = 2
        basicOffer.stamp_family(:de).must_equal 'für Kinder (bis 2 Jahre)'

        basicOffer.age_from = 2
        basicOffer.stamp_family(:de).must_equal 'für Kinder (2 Jahre)'

        basicOffer.age_to = 18
        basicOffer.stamp_family(:de).must_equal 'für Kinder und Jugendliche (ab 2 Jahren)'

        basicOffer.age_to = 99
        basicOffer.stamp_family(:de).must_equal 'für Kinder und Jugendliche (ab 2 Jahren)'

        basicOffer.age_visible = false
        basicOffer.stamp_family(:de).must_equal 'für Kinder und Jugendliche'

        basicOffer.age_visible = true
        basicOffer.target_audience_filters =
          [TargetAudienceFilter.find_by(identifier: 'family_everyone')]
        basicOffer.stamp_family(:de).must_equal 'für alle'
      end

      it 'should behave correctly for family_children target_audience' do
        basicOffer.age_visible = true
        basicOffer.age_from = 1
        basicOffer.age_to = 2
        basicOffer.stamp_family(:de).must_equal 'für Kinder (1 – 2 Jahre)'

        basicOffer.age_from = 15
        basicOffer.age_to = 16
        basicOffer.stamp_family(:de).must_equal 'für Jugendliche (15 – 16 Jahre)'

        basicOffer.age_from = 7
        basicOffer.age_to = 16
        basicOffer.stamp_family(:de).must_equal 'für Kinder und Jugendliche (7 – 16 Jahre)'

        basicOffer.gender_first_part_of_stamp = 'male'
        basicOffer.stamp_family(:de).must_equal 'für Jungen (7 – 16 Jahre)'

        basicOffer.gender_first_part_of_stamp = 'female'
        basicOffer.stamp_family(:de).must_equal 'für Mädchen (7 – 16 Jahre)'
      end

      it 'should behave correctly for family_parents target_audience' do
        basicOffer.target_audience_filters =
          [TargetAudienceFilter.find_by(identifier: 'family_parents')]
        basicOffer.age_visible = true
        basicOffer.age_from = 1
        basicOffer.age_to = 2
        basicOffer.stamp_family(:de).must_equal 'für Eltern (1 – 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'neutral'
        basicOffer.stamp_family(:de).must_equal 'für Eltern (Alter des Kindes: 1 – 2 Jahre)'

        basicOffer.gender_first_part_of_stamp = 'female'
        basicOffer.stamp_family(:de).must_equal 'für Mütter (Alter des Kindes: 1 – 2 Jahre)'

        basicOffer.gender_first_part_of_stamp = 'male'
        basicOffer.stamp_family(:de).must_equal 'für Väter (Alter des Kindes: 1 – 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'male'
        basicOffer.stamp_family(:de).must_equal 'für Väter von Söhnen (1 – 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'female'
        basicOffer.stamp_family(:de).must_equal 'für Väter von Töchtern (1 – 2 Jahre)'

        basicOffer.gender_first_part_of_stamp = ''
        basicOffer.stamp_family(:de).must_equal 'für Eltern von Töchtern (1 – 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'male'
        basicOffer.stamp_family(:de).must_equal 'für Eltern von Söhnen (1 – 2 Jahre)'

        basicOffer.gender_first_part_of_stamp = 'female'
        basicOffer.stamp_family(:de).must_equal 'für Mütter von Söhnen (1 – 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'female'
        basicOffer.stamp_family(:de).must_equal 'für Mütter von Töchtern (1 – 2 Jahre)'
      end

      it 'should behave correctly for family_nuclear_family target_audience' do
        basicOffer.target_audience_filters =
          [TargetAudienceFilter.find_by(identifier: 'family_nuclear_family')]
        basicOffer.stamp_family(:de).must_equal 'für Familien'

        basicOffer.gender_second_part_of_stamp = 'neutral'
        basicOffer.age_from = 0
        basicOffer.age_to = 1
        basicOffer.stamp_family(:de).must_equal 'für Familien und ihre Babys'

        basicOffer.age_visible = true
        basicOffer.age_from = 1
        basicOffer.age_to = 2
        basicOffer.stamp_family(:de).must_equal 'für Familien und ihre Kinder (1 – 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = ''
        basicOffer.stamp_family(:de).must_equal 'für Familien'

        basicOffer.age_visible = false
        basicOffer.gender_second_part_of_stamp = 'neutral'
        basicOffer.stamp_family(:de).must_equal 'für Familien'

        basicOffer.age_visible = true
        basicOffer.gender_second_part_of_stamp = 'male'
        basicOffer.stamp_family(:de).must_equal 'für Familien und ihre Söhne (1 – 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'female'
        basicOffer.stamp_family(:de).must_equal 'für Familien und ihre Töchter (1 – 2 Jahre)'

        basicOffer.gender_first_part_of_stamp = 'female'
        basicOffer.gender_second_part_of_stamp = 'neutral'
        basicOffer.stamp_family(:de).must_equal 'für Mütter und ihre Kinder (1 – 2 Jahre)'

        basicOffer.gender_first_part_of_stamp = 'male'
        basicOffer.stamp_family(:de).must_equal 'für Väter und ihre Kinder (1 – 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'male'
        basicOffer.stamp_family(:de).must_equal 'für Väter und ihre Söhne (1 – 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'female'
        basicOffer.stamp_family(:de).must_equal 'für Väter und ihre Töchter (1 – 2 Jahre)'

        basicOffer.gender_first_part_of_stamp = 'female'
        basicOffer.stamp_family(:de).must_equal 'für Mütter und ihre Töchter (1 – 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = nil
        basicOffer.stamp_family(:de).must_equal 'für Mütter und ihre Kinder (1 – 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'male'
        basicOffer.stamp_family(:de).must_equal 'für Mütter und ihre Söhne (1 – 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'neutral'
        basicOffer.stamp_family(:de).must_equal 'für Mütter und ihre Kinder (1 – 2 Jahre)'
      end

      it 'should behave correctly for family_parents_to_be target_audience' do
        basicOffer.target_audience_filters =
          [TargetAudienceFilter.find_by(identifier: 'family_parents_to_be')]
        basicOffer.stamp_family(:de).must_equal 'für werdende Eltern'

        basicOffer.gender_second_part_of_stamp = 'neutral'
        basicOffer.stamp_family(:de).must_equal 'für werdende Eltern und ihre Kinder'

        basicOffer.gender_second_part_of_stamp = 'male'
        basicOffer.stamp_family(:de).must_equal 'für werdende Eltern und ihre Söhne'

        basicOffer.gender_second_part_of_stamp = 'female'
        basicOffer.stamp_family(:de).must_equal 'für werdende Eltern und ihre Töchter'

        basicOffer.gender_first_part_of_stamp = 'female'
        basicOffer.gender_second_part_of_stamp = ''
        basicOffer.stamp_family(:de).must_equal 'für Schwangere'

        basicOffer.gender_first_part_of_stamp = 'male'
        basicOffer.stamp_family(:de).must_equal 'für werdende Väter'

        basicOffer.gender_second_part_of_stamp = 'neutral'
        basicOffer.stamp_family(:de).must_equal 'für werdende Väter und ihre Kinder'

        basicOffer.gender_second_part_of_stamp = 'male'
        basicOffer.stamp_family(:de).must_equal 'für werdende Väter und ihre Söhne'

        basicOffer.gender_second_part_of_stamp = 'female'
        basicOffer.stamp_family(:de).must_equal 'für werdende Väter und ihre Töchter'

        basicOffer.gender_first_part_of_stamp = 'female'
        basicOffer.stamp_family(:de).must_equal 'für Schwangere und ihre Töchter'

        basicOffer.gender_second_part_of_stamp = 'male'
        basicOffer.stamp_family(:de).must_equal 'für Schwangere und ihre Söhne'

        basicOffer.gender_second_part_of_stamp = 'neutral'
        basicOffer.stamp_family(:de).must_equal 'für Schwangere und ihre Kinder'
      end

      it 'should behave correctly for the remaining family target audiences' do
        basicOffer.target_audience_filters =
          [TargetAudienceFilter.find_by(identifier: 'family_relatives')]
        basicOffer.stamp_family(:de).must_equal 'für Angehörige'

        basicOffer.age_visible = true
        basicOffer.gender_second_part_of_stamp = 'neutral'
        basicOffer.age_from = 1
        basicOffer.age_to = 2
        basicOffer.stamp_family(:de).must_equal 'für Angehörige (Alter des Kindes: 1 – 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = nil
        basicOffer.stamp_family(:de).must_equal 'für Angehörige (1 – 2 Jahre)'

        basicOffer.target_audience_filters =
          [TargetAudienceFilter.find_by(identifier: 'family_everyone')]
        basicOffer.stamp_family(:de).must_equal 'für alle'
      end

      it 'should behave correctly for refugees_children target_audience' do
        basicOffer.target_audience_filters =
          [TargetAudienceFilter.create(name: 'ref_1', identifier: 'refugees_children')]
        basicOffer.age_from = 1
        basicOffer.age_to = 10
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Kinder'
        basicOffer.stamp_family(:de).must_equal ''

        basicOffer.age_to = 17
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Kinder und Jugendliche'

        basicOffer.age_from = 15
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Jugendliche'

        basicOffer.age_visible = true
        basicOffer.age_from = 13
        basicOffer.age_to = 17
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Kinder und Jugendliche (13 – 17 Jahre)'

        basicOffer.gender_first_part_of_stamp = 'male'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Jungen (13 – 17 Jahre)'

        basicOffer.gender_first_part_of_stamp = 'female'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Mädchen (13 – 17 Jahre)'

        # neutral equals nil
        basicOffer.gender_first_part_of_stamp = 'neutral'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Kinder und Jugendliche (13 – 17 Jahre)'
      end

      it 'should behave correctly for refugees_umf target_audience' do
        basicOffer.target_audience_filters =
          [TargetAudienceFilter.create(name: 'ref_1', identifier: 'refugees_umf')]
        basicOffer.stamp_refugees(:de).must_equal 'für unbegleitete minderjährige Flüchtlinge'
        basicOffer.stamp_family(:de).must_equal ''

        # neutral equals nil
        basicOffer.gender_first_part_of_stamp = 'neutral'
        basicOffer.stamp_refugees(:de).must_equal 'für unbegleitete minderjährige Flüchtlinge'

        basicOffer.gender_first_part_of_stamp = 'male'
        basicOffer.stamp_refugees(:de).must_equal 'für unbegleitete minderjährige Jungen'

        basicOffer.gender_first_part_of_stamp = 'female'
        basicOffer.stamp_refugees(:de).must_equal 'für unbegleitete minderjährige Mädchen'
      end

      it 'should behave correctly for refugees_parents_to_be target_audience' do
        basicOffer.target_audience_filters =
          [TargetAudienceFilter.create(name: 'ref_1', identifier: 'refugees_parents_to_be')]
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete werdende Eltern'
        basicOffer.stamp_family(:de).must_equal ''

        # neutral equals nil
        basicOffer.gender_first_part_of_stamp = 'neutral'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete werdende Eltern'

        basicOffer.gender_first_part_of_stamp = 'female'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Schwangere'

        basicOffer.gender_first_part_of_stamp = 'male'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete werdende Väter'
      end

      it 'should behave correctly for refugees_parents target_audience' do
        basicOffer.target_audience_filters =
          [TargetAudienceFilter.create(name: 'ref_1', identifier: 'refugees_parents')]
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Eltern'
        basicOffer.stamp_family(:de).must_equal ''

        # neutral equals nil
        basicOffer.gender_first_part_of_stamp = 'neutral'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Eltern'

        basicOffer.gender_second_part_of_stamp = 'neutral'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Eltern'

        basicOffer.age_visible = true
        basicOffer.age_from = 1
        basicOffer.age_to = 2
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Eltern (Alter des Kindes: 1 – 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'female'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Eltern von Töchtern (1 – 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'male'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Eltern von Söhnen (1 – 2 Jahre)'

        basicOffer.gender_first_part_of_stamp = 'male'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Väter von Söhnen (1 – 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'female'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Väter von Töchtern (1 – 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'neutral'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Väter (Alter des Kindes: 1 – 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = nil
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Väter (1 – 2 Jahre)'

        basicOffer.gender_first_part_of_stamp = 'female'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Mütter (1 – 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'neutral'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Mütter (Alter des Kindes: 1 – 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'male'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Mütter von Söhnen (1 – 2 Jahre)'

        basicOffer.gender_second_part_of_stamp = 'female'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Mütter von Töchtern (1 – 2 Jahre)'
      end

      it 'should behave correctly for refugees_families target_audience' do
        basicOffer.target_audience_filters =
          [TargetAudienceFilter.create(name: 'ref_1', identifier: 'refugees_families')]
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Familien'
        basicOffer.stamp_family(:de).must_equal ''

        # neutral equals nil
        basicOffer.gender_first_part_of_stamp = 'neutral'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Familien'

        basicOffer.age_visible = true
        basicOffer.gender_second_part_of_stamp = 'neutral' # neutral equals nil
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Familien und ihre Kinder (bis 17 Jahre)'

        basicOffer.age_from = 0
        basicOffer.age_to = 1
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Familien und ihre Babys (bis 1 Jahr)'

        basicOffer.age_visible = false
        basicOffer.gender_second_part_of_stamp = 'female'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Familien und ihre Töchter'

        basicOffer.gender_second_part_of_stamp = 'male'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Familien und ihre Söhne'

        basicOffer.gender_first_part_of_stamp = 'female'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Mütter und ihre Söhne'

        basicOffer.gender_second_part_of_stamp = 'female'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Mütter und ihre Töchter'

        basicOffer.gender_second_part_of_stamp = 'neutral'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Mütter und ihre Babys'

        basicOffer.age_from = 1
        basicOffer.age_to = 2
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Mütter und ihre Kinder'

        basicOffer.gender_first_part_of_stamp = 'male'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Väter und ihre Kinder'

        basicOffer.age_from = 0
        basicOffer.age_to = 1
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Väter und ihre Babys'

        basicOffer.gender_second_part_of_stamp = 'male'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Väter und ihre Söhne'

        basicOffer.gender_second_part_of_stamp = 'female'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Väter und ihre Töchter'
      end

      it 'should behave correctly for refugees_general target_audience' do
        basicOffer.target_audience_filters =
          [TargetAudienceFilter.create(name: 'ref_1', identifier: 'refugees_general')]
        basicOffer.stamp_refugees(:de).must_equal 'für Flüchtlinge'
        basicOffer.stamp_family(:de).must_equal ''

        # neutral equals nil
        basicOffer.gender_first_part_of_stamp = 'neutral'
        basicOffer.stamp_refugees(:de).must_equal 'für Flüchtlinge'

        basicOffer.gender_first_part_of_stamp = 'female'
        basicOffer.age_from = 15
        basicOffer.age_to = 42
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Mädchen und Frauen'

        basicOffer.gender_first_part_of_stamp = 'male'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Jungen und Männer'

        basicOffer.age_from = 18
        basicOffer.age_to = 42
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Männer'

        basicOffer.gender_first_part_of_stamp = 'female'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Frauen'

        # simple residency_status tests
        basicOffer.residency_status = 'before_the_asylum_application'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Frauen – vor dem Asylantrag'

        basicOffer.residency_status = 'during_the_asylum_procedure'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Frauen – im Asylverfahren'

        basicOffer.residency_status = 'with_a_residence_permit'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Frauen – mit Aufenthaltserlaubnis'

        basicOffer.residency_status = 'with_temporary_suspension_of_deportation'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Frauen – mit Duldung'

        basicOffer.residency_status = 'with_deportation_decision'
        basicOffer.stamp_refugees(:de).must_equal 'für geflüchtete Frauen – mit Abschiebebescheid'
      end
    end
  end
end
