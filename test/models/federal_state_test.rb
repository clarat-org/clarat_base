require_relative '../test_helper'

describe FederalState do
  let(:federal_state) { federal_states(:basic) }

  subject { federal_state }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :name }
    it { subject.must_respond_to :created_at }
    it { subject.must_respond_to :updated_at }
  end

  describe '::Base' do
    describe 'associations' do
      it { subject.must have_many :locations }
    end
  end

  describe 'locations' do
    before do
      location = locations(:basic)
      subject.locations << location
    end

    it 'should not delete federal state' do
      assert_raises(ActiveRecord::DeleteRestrictionError) { subject.destroy }
    end

    it 'should delete federal state when there is no location' do
      subject.locations.each { |l| l.offers.destroy_all }
      subject.locations.destroy_all
      subject.destroy
      assert_raises(ActiveRecord::RecordNotFound) { subject.reload }
    end
  end
end
