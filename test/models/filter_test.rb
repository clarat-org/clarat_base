require_relative '../test_helper'

describe Filter do
  let(:filter) { Filter.new }

  subject { filter }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :name }
    it { subject.must_respond_to :identifier }
    it { subject.must_respond_to :created_at }
    it { subject.must_respond_to :updated_at }
    it { subject.must_respond_to :section_filter_id }
  end

  describe 'validations' do
    describe 'always' do
      it { subject.must validate_presence_of :name }
      it { subject.must validate_uniqueness_of :name }
      it { subject.must validate_presence_of :identifier }
      it { subject.must validate_uniqueness_of :identifier }
    end

    describe 'LanguageFilter' do
      it { LanguageFilter.new.must validate_length_of(:identifier).is_equal_to 3 }
    end

    describe 'TargetAudienceFilter' do
      it { TargetAudienceFilter.new.must belong_to :section_filter }
    end

    describe 'SectionFilter' do
      it { SectionFilter.new.must have_many :target_audience_filters }
    end
  end

  describe '::Base' do
    describe 'associations' do
      it { subject.must have_many :offers }
    end
  end

  describe 'TraitFilter' do
    it 'has an identifier array' do
      TraitFilter::IDENTIFIER.wont_be :nil?
    end
  end
end
