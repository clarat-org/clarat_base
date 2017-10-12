require_relative '../test_helper'

describe SplitBase do
  let(:split_base) { SplitBase.new }
  subject { split_base }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :title }
    it { subject.must_respond_to :clarat_addition }
    it { subject.must_respond_to :comments }
    it { subject.must_respond_to :created_at }
    it { subject.must_respond_to :updated_at }
    it { subject.must_respond_to :label }
  end

  describe 'associations' do
    it { subject.must have_many :offers }
    it { subject.must have_many(:split_base_divisions) }
    it { subject.must have_many(:divisions).through :split_base_divisions }
    it { subject.must have_many(:organizations).through :divisions }
    it { subject.must belong_to :solution_category }
  end
end
