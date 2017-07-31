require_relative '../test_helper'

describe Division do
  let(:division) { Division.new }
  subject { division }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :addition }
    it { subject.must_respond_to :created_at }
    it { subject.must_respond_to :updated_at }
  end

  describe '::Base' do
    describe 'associations' do
      it { subject.must belong_to :section }
      it { subject.must belong_to :city }
      it { subject.must belong_to :area }
      it { subject.must belong_to :organization }
      it { subject.must have_many(:split_base_divisions) }
      it { subject.must have_many(:split_bases).through :split_base_divisions }
      it { subject.must have_many(:offers).through :split_bases }
    end
  end
end
