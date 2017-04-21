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
