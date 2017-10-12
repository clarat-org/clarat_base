require_relative '../test_helper'

describe Location do
  # Using 'let' because 'ArgumentError: let 'location' cannot override a method in Minitest::Spec. Please use another name.'
  let(:loc) { Location.new }

  subject { loc }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :street }
    it { subject.must_respond_to :addition }
    it { subject.must_respond_to :zip }
    it { subject.must_respond_to :hq }
    it { subject.must_respond_to :latitude }
    it { subject.must_respond_to :longitude }
    it { subject.must_respond_to :organization_id }
    it { subject.must_respond_to :federal_state_id }
    it { subject.must_respond_to :city_id }
    it { subject.must_respond_to :name }
    it { subject.must_respond_to :label }
    it { subject.must_respond_to :created_at }
    it { subject.must_respond_to :updated_at }
    it { subject.must_respond_to :visible }
    it { subject.must_respond_to :in_germany }
  end

  describe '::Base' do
    describe 'associations' do
      it { subject.must have_many :offers }
      it { subject.must belong_to :organization }
      it { subject.must belong_to :federal_state }
    end
  end

  # this method is stubbed out for the entire rest of the test suite
  describe '#full_address' do
    it 'should return address and federal state name' do
      loc.assign_attributes street: 'street',
                            zip: 'zip',
                            city: City.new(name: 'city'),
                            federal_state: FederalState.new(name: 'state')

      loc.send(:full_address).must_equal 'street, zip city state'
    end
  end
end
