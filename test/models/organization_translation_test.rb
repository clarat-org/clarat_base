require_relative '../test_helper'

describe OrganizationTranslation do
  let(:organization_translation) { OrganizationTranslation.new }
  subject { organization_translation }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :organization }
  end

  describe '::Base' do
    describe 'associations' do
      it { subject.must have_many(:sections).through :organization }
    end
  end

  describe '#translated_class' do
    it 'must return the correct class' do
      OrganizationTranslation.translated_class.must_equal Organization
    end
  end
end
