require_relative '../test_helper'

describe Area do
  let(:area) { areas(:ger) }
  subject { area }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :name }
    it { subject.must_respond_to :minlat }
    it { subject.must_respond_to :maxlat }
    it { subject.must_respond_to :minlong }
    it { subject.must_respond_to :maxlong }
  end

  describe 'offers' do
    before do
      offer = offers(:basic)
      subject.offers << offer
    end

    it 'should respond to offers' do
      subject.offers.count.must_equal 1
    end

    it 'should not delete area' do
      assert_raises(ActiveRecord::DeleteRestrictionError) { subject.destroy }
    end

    it 'should delete area when there is no offer' do
      subject.offers.destroy_all
      subject.destroy
      assert_raises(ActiveRecord::RecordNotFound) { subject.reload }
    end
  end

  describe 'divisions' do
    before do
      division = divisions(:basic)
      subject.divisions << division
    end

    it 'should respond to division' do
      subject.divisions.count.must_equal 1
    end

    it 'should not delete area' do
      assert_raises(ActiveRecord::DeleteRestrictionError) { subject.destroy }
    end

    it 'should delete area when there is no division' do
      subject.divisions.destroy_all
      subject.reload.destroy
      assert_raises(ActiveRecord::RecordNotFound) { subject.reload }
    end
  end
end
