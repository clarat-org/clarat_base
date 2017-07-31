require_relative '../test_helper'

class TestClass
  # rubocop:disable Style/PredicateName
  def self.has_many *_args; end
  # rubocop:enable Style/PredicateName

  include Translation

  attr_accessor :somefield
  translate :somefield
end

describe Translation do
  subject { TestClass.new }
  let(:translation) do
    OpenStruct.new(somefield: 'some translation', locale: 'en')
  end

  let(:empty_translation) do
    OpenStruct.new(somefield: '', locale: 'en')
  end

  describe 'methods' do
    describe 'translated field getter' do
      it 'should find the content of a translation with translated_field' do
        subject.expect_chain(:translations, :find_by).returns(translation)
        subject.translated_somefield.must_equal 'some translation'
      end

      it 'should fallback to source field if the translation is empty' do
        subject.expect_chain(:translations, :find_by).returns(empty_translation)
        assert_nil subject.translated_somefield
      end
    end
  end

  describe 'field getter for specific translation' do
    it 'should find a specific translation' do
      subject.expect_chain(:translations, :where, :select).returns [translation]
      subject.somefield_en.must_equal 'some translation'
    end
  end

  describe 'automated translation check' do
    it 'should call the check on the current translation' do
      translation = OfferTranslation.new(source: 'GoogleTranslate')
      subject.expect_chain(:translations, :find_by).returns translation
      subject.translation_automated?.must_equal true
    end
  end

  describe 'changed_translatable_fields' do
    it 'should correctly return the changed translatable fields' do
      offer = FactoryGirl.create(:offer)
      # contains all translatable fields for new records
      offer.changed_translatable_fields.must_equal [:name, :description, :old_next_steps]
      offer.description = 'SomeOtherText'
      offer.save!
      # contains only the changed field
      offer.changed_translatable_fields.must_equal [:description]
    end
  end

  describe 'cache key' do
    it 'should set the cache key to include the current locale' do
      # TestClass doesn't have super; we need an AR model including Translation
      Offer.new.cache_key.must_match(/.+de/)
    end
  end
end
