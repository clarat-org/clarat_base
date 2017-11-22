require_relative '../test_helper'

describe LogicVersion do
  let(:logic_version) { logic_versions(:basic) }
  subject { logic_version }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :version }
    it { subject.must_respond_to :name }
    it { subject.must_respond_to :description }
  end

  describe 'offers' do
    before do
      offer = offers(:basic)
      subject.offers << offer
    end

    it 'should not delete logic version' do
      assert_raises(ActiveRecord::DeleteRestrictionError) { subject.destroy }
    end

    it 'should delete logic version when there is no offer' do
      subject.offers.destroy_all
      subject.reload.destroy
      assert_raises(ActiveRecord::RecordNotFound) { subject.reload }
    end
  end
end
