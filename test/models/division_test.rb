require_relative '../test_helper'

describe Division do
  let(:division) { Division.new }
  subject { division }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :name }
    it { subject.must_respond_to :description }
    it { subject.must_respond_to :created_at }
    it { subject.must_respond_to :updated_at }
  end

  describe '::Base' do
    describe 'associations' do
      it { subject.must belong_to :organization }
      it { subject.must belong_to :section }
    end
  end
end
