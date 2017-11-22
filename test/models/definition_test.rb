require_relative '../test_helper'

describe Definition do
  let(:definition) { definitions(:basic) }
  subject { definition }

  it 'must be valid' do
    definition.must_be :valid?
  end

  describe 'attributes' do
    it { subject.must_respond_to :key }
    it { subject.must_respond_to :explanation }
  end

  describe '::Base' do
    describe 'associations' do
      it { subject.must have_many :definitions_organizations }
      it {
        subject.must have_many(:organizations)
          .through :definitions_organizations
      }
      it { subject.must have_many :definitions_offers }
      it { subject.must have_many(:offers).through :definitions_offers }
    end
  end

  describe 'offers' do
    before do
      @offer = offers(:basic)
      subject.offers << @offer
      @definitions_offer = subject.definitions_offers.first
      subject.destroy
    end

    it 'will destroy definitions offers' do
      assert_raises(ActiveRecord::RecordNotFound) do
        @definitions_offer.reload
      end
    end

    it 'will not destroy offers' do
      refute_nil @offer.reload
    end
  end

  describe 'organization' do
    before do
      @organization = organizations(:basic)
      subject.organizations << @organization
      @definitions_organization = subject.definitions_organizations.first
      subject.destroy
    end

    it 'will destroy definitions organizations' do
      assert_raises(ActiveRecord::RecordNotFound) do
        @definitions_organization.reload
      end
    end

    it 'will not destroy organizations' do
      refute_nil @organization.reload
    end
  end
end
