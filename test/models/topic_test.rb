require_relative '../test_helper'

describe Topic do
  let(:topic) { topics(:basic) }

  subject { topic }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :name }
  end

  describe '::Base' do
    describe 'associations' do
      it { subject.must have_many :topics_organizations }
      it { subject.must have_many(:organizations).through :topics_organizations }
    end
  end

  describe 'organization' do
    before do
      @orga = organizations(:basic)
      subject.organizations << @orga
      @topics_orga = subject.topics_organizations.first
      subject.destroy
    end

    it 'will destroy topics organizations' do
      assert_raises(ActiveRecord::RecordNotFound) do
        @topics_orga.reload
      end
    end

    it 'will not destroy organizations' do
      refute_nil @orga.reload
    end
  end
end
