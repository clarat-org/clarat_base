require_relative '../test_helper'

describe ContactPersonTranslation do
  let(:organization_translation) { ContactPersonTranslation.new }
  subject { organization_translation }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :contact_person }
  end

  describe '#translated_class' do
    it 'must return the correct class' do
      ContactPersonTranslation.translated_class.must_equal ContactPerson
    end
  end
end
