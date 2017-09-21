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
    it { subject.must_respond_to :target_audience }
    it { subject.must_respond_to :hide_contact_people }
    it { subject.must_respond_to :code_word }
    it { subject.must_respond_to :logic_version_id }
    it { subject.must_respond_to :split_base_id }
    it { subject.must_respond_to :all_inclusive }
    it { subject.must_respond_to :starts_at }
    it { subject.must_respond_to :completed_at }
    it { subject.must_respond_to :completed_by }
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
      it { subject.must have_one(:solution_category).through :split_base }
      it { subject.must belong_to :logic_version }
      it { subject.must belong_to :split_base }
      it { subject.must have_many(:divisions).through :split_base }
      it { subject.must have_many(:organizations).through :split_base }
      it { subject.must have_and_belong_to_many :categories }
      it { subject.must have_many(:filters).through :filters_offers }
      it { subject.must belong_to :section }
      it { subject.must have_many(:language_filters).through :filters_offers }
      it { subject.must have_many(:trait_filters).through :filters_offers }
      it { subject.must have_many(:target_audience_filters).through :target_audience_filters_offers }
      it { subject.must have_and_belong_to_many :openings }
      it { subject.must have_many :hyperlinks }
      it { subject.must have_many :websites }
    end
  end

  describe 'methods' do
    describe '#_categories' do
      it 'should return unique categories with ancestors of an offer' do
        offers(:basic).categories << categories(:sub1)
        offers(:basic).categories << categories(:sub2)
        tags = offers(:basic)._categories(:de)
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
        tags = offers(:basic)._categories(:en)
        tags.must_include 'ensub1.1'
        tags.must_include 'enmain1'
      end
    end

    describe '#_keywords' do
      it 'should return unique keywords of offer categories' do
        Category.find(1).update_column :keywords_de, 'foo, bar'
        Category.find(3).update_column :keywords_de, 'bar, code me'
        offers(:basic).categories << Category.find(1)
        offers(:basic).categories << Category.find(3)
        tags = offers(:basic)._keywords(:de)
        tags.must_include 'foo'
        tags.must_include 'bar'
        tags.must_include 'code me'
        tags.count('bar').must_equal 1
        tags.count(' bar').must_equal 0
      end
    end

    describe '#category_keywords' do
      it 'should return unique keywords of offer categories' do
        Category.find(1).update_column :keywords_de, 'foo, bar'
        Category.find(3).update_column :keywords_de, 'bar, code me'
        offers(:basic).categories << Category.find(1)
        offers(:basic).categories << Category.find(3)
        offers(:basic).category_keywords.must_equal 'foo bar code me'
      end

      it 'should return unique keywords of offer categories including parent' do
        category = categories(:sub1)
        category.parent = categories(:main2)
        offers(:basic).categories << category
        offers(:basic).category_keywords.must_equal 'main1kw sub1kw'
      end
    end

    describe '#category_explanations' do
      it 'should return unique explanations of offer categories' do
        Category.find(1).update_column :explanations_de, 'foo, bar'
        Category.find(2).update_column :explanations_de, 'foo, bar'
        Category.find(3).update_column :explanations_de, 'bar, code me'
        offers(:basic).categories << Category.find(1)
        offers(:basic).categories << Category.find(2)
        offers(:basic).categories << Category.find(3)
        offers(:basic).category_explanations.must_equal 'foo, bar, bar, code me'
      end
    end

    describe '#category_names' do
      it 'should refer to tags to gather category information' do
        offer = offers(:basic)
        offer.expect_chain(:_categories, :join).once
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
        offers(:basic).split_base.divisions << FactoryGirl.create(:division)
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

    # describe '#target_audience_filters?' do
    #   it 'should behave correctly in family section' do
    #     offer = offers(:basic)
    #     offer.section = sections(:family)
    #     offer.expects(:fail_validation).never
    #     offer.send :validate_associated_fields
    #     offer.target_audience_filters = []
    #     offer.expects(:fail_validation).with :target_audience_filters,
    #                                          'needs_target_audience_filters'
    #     offer.send :validate_target_audience_filters
    #   end
    #
    #   it 'should behave correctly in refugees section' do
    #     offer = offers(:basic)
    #     offer.section = sections(:refugees)
    #     offer.expects(:fail_validation).never
    #     offer.send :validate_associated_fields
    #     offer.target_audience_filters = []
    #     offer.expects(:fail_validation).with :target_audience_filters,
    #                                          'needs_target_audience_filters'
    #     offer.send :validate_target_audience_filters
    #   end
    # end

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
        basicOffer._geoloc.must_equal('lat' => loc.latitude, 'lng' => loc.longitude)
      end

      it 'should correctly return tags_string' do
        basicOffer.tags << tags(:basic)
        basicOffer.tag_string.must_include 'synonym'
        basicOffer.tag_string.must_include 'test'
        basicOffer.tag_string.must_include 'en_xplanations'
      end

      it 'should correctly return definitions_string' do
        definition = Definition.new key: 'foo', explanation: 'bar'
        basicOffer.definitions << definition
        basicOffer.definitions_string.must_include 'bar'
      end

      it 'should correctly return age_filters' do
        basicOffer._age_filters.must_equal((0..20).to_a)
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
        basicOffer.target_audience_filters_offers.first.update_columns(
          gender_first_part_of_stamp: 'female'
        )
        basicOffer._exclusive_gender_filters.must_equal(['female'])
      end

      it 'should correctly return target_audience_filters' do
        basicOffer._target_audience_filters.must_equal(['family_children'])
      end

      it 'should correctly return uniq target_audience_filters' do
        basicOffer.target_audience_filters <<
          TargetAudienceFilter.find_by(identifier: 'family_children')
        basicOffer.target_audience_filters.count.must_equal 2
        basicOffer.target_audience_filters.pluck(:identifier).must_equal(
          %w(family_children family_children)
        )
        basicOffer._target_audience_filters.must_equal(['family_children'])
      end

      it 'should correctly return language_filters' do
        basicOffer._language_filters.must_equal(['deu'])
      end

      it 'should correctly return stamps_string' do
        # stamp-generation logic moved to backend so we just set the stamps
        basicOffer.target_audience_filters_offers.first
                  .update_columns stamp_de: 'foo', stamp_en: 'bar'
        basicOffer.stamps_string(:de).must_equal 'foo'
        basicOffer.stamps_string(:en).must_equal 'bar'
      end

      it 'should correctly return stamps_string for multiple filters' do
        # stamp-generation logic moved to backend so we just set the stamps
        basicOffer.target_audience_filters_offers.first
                  .update_columns stamp_de: 'für Kinder'
        TargetAudienceFiltersOffer.create!(
          offer_id: basicOffer.id, target_audience_filter_id: 4,
          stamp_de: 'für Eltern'
        )
        basicOffer.stamps_string(:de).must_equal 'für Kinder, für Eltern'
      end

      it 'should correctly return singular_stamp' do
        # stamp-generation logic moved to backend so we just set the stamps
        basicOffer.target_audience_filters_offers.first
                  .update_columns stamp_de: 'foo', stamp_en: 'bar'
        basicOffer.singular_stamp(:de).must_equal 'foo'
        basicOffer.singular_stamp(:en).must_equal 'bar'
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
        basicOffer.aasm_state = 'under_construction'
        basicOffer.visible_in_frontend?.must_equal false
      end
    end
  end
end
