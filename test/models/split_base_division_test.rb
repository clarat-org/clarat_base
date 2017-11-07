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
end
