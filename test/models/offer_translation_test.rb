require_relative '../test_helper'

describe OfferTranslation do
  let(:offer_translation) { OfferTranslation.new }
  subject { offer_translation }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :offer }
  end

  describe '::Base' do
    describe 'associations' do
      it { subject.must have_one(:section).through :offer }
    end
  end

  describe '#translated_class' do
    it 'must return the correct class' do
      OfferTranslation.translated_class.must_equal Offer
    end
  end
end
