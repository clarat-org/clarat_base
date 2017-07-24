require_relative '../test_helper'

describe SplitBaseDivision do
  let(:split_base_division) { SplitBaseDivision.new }

  subject { split_base_division }

  it { subject.must_be :valid? }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :split_base }
    it { subject.must_respond_to :split_base_id }
    it { subject.must_respond_to :division }
    it { subject.must_respond_to :division_id }
  end

  describe 'callbacks' do
    it 'should be destroyed when division is destroyed' do
      item = split_base_divisions(:basic)
      split_base = SplitBase.find(item.split_base_id)
      item.division.destroy!
      assert_raises(ActiveRecord::RecordNotFound) { item.reload }
      split_base.reload # split_base still exists
    end

    it 'should be destroyed when split_base is destroyed' do
      item = split_base_divisions(:basic)
      division = Division.find(item.division_id)
      item.split_base.destroy!
      assert_raises(ActiveRecord::RecordNotFound) { item.reload }
      division.reload # division still exists
    end
  end
end
