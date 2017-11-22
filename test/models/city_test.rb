require_relative '../test_helper'

describe City do
  let(:city) { cities(:basic) }

  subject { city }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :name }
    it { subject.must_respond_to :created_at }
    it { subject.must_respond_to :updated_at }
  end

  describe '::Base' do
    describe 'associations' do
      it { subject.must have_many :locations }
      it { subject.must have_many :divisions }
      it { subject.must have_many(:offers).through :locations }
      it { subject.must have_many(:organizations).through :locations }
    end
  end

  describe 'locations and division' do
    it 'should not delete city when it has dependent associations' do
      assert_raises(ActiveRecord::DeleteRestrictionError) { subject.destroy }
    end

    it 'should delete city when there are no offers and locations' do
      subject.locations.each { |l| l.offers.destroy_all }
      subject.locations.destroy_all
      subject.divisions.destroy_all
      subject.reload.destroy
      assert_raises(ActiveRecord::RecordNotFound) { subject.reload }
    end
  end
end
