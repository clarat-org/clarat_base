require_relative '../test_helper'

describe NextStep do
  let(:next_step) { NextStep.new }
  subject { next_step }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it 'must have a text_* for every available locale' do
      I18n.available_locales.each do |locale|
        subject.must_respond_to "text_#{locale}"
      end
    end
  end

  describe 'validations' do
    it { subject.must validate_presence_of :text_de }
    it { subject.must validate_presence_of :text_en }
    it { subject.must validate_length_of(:text_de).is_at_most 255 }
    it { subject.must validate_length_of(:text_en).is_at_most 255 }
    it { subject.must validate_length_of(:text_ar).is_at_most 255 }
    it { subject.must validate_length_of(:text_fr).is_at_most 255 }
    it { subject.must validate_length_of(:text_tr).is_at_most 255 }
    it { subject.must validate_length_of(:text_pl).is_at_most 255 }
    it { subject.must validate_length_of(:text_ru).is_at_most 255 }
    it { subject.must validate_length_of(:text_fa).is_at_most 255 }
  end

  describe 'methods' do
    describe '#text' do
      it 'should show text_[locale] for the current locale' do
        locale = I18n.available_locales.sample
        subject.send("text_#{locale}=", 'foobar')
        I18n.with_locale(locale) do
          subject.text.must_equal 'foobar'
        end
      end

      it 'should fall back to the en locale when the current one is empty' do
        subject.text_de = 'foo'
        subject.text_en = 'bar'
        subject.text_ar = ''
        I18n.with_locale(:ar) { subject.text.must_equal('bar') }
      end

      it 'should fall back to de locale when the current one & en are empty' do
        subject.text_de = 'foo'
        subject.text_en = ''
        subject.text_ar = nil
        I18n.with_locale(:ar) { subject.text.must_equal('foo') }
      end
    end
  end
end
