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
    it { subject.must_respond_to :display_name }
    it { subject.must_respond_to :created_at }
    it { subject.must_respond_to :updated_at }
    it { subject.must_respond_to :visible }
    it { subject.must_respond_to :in_germany }
  end

  describe 'validations' do
    describe 'always' do
      it { subject.must validate_length_of(:name).is_at_most 100 }
      it { subject.must validate_presence_of :street }
      it { subject.must validate_presence_of :zip }
      it { subject.must validate_length_of(:zip).is_equal_to 5 }
      it { subject.must validate_presence_of :city_id }
      it { subject.must validate_presence_of :organization_id }
      it { subject.must validate_presence_of :federal_state_id }
    end

    describe 'when location is not in germany' do
      before do
        # valid location in germany
        loc.assign_attributes street: 'street 1',
                              city_id: 1,         # fixture City
                              organization_id: 1, # fixture Orga
                              federal_state_id: 1 # fixture federal_state
      end

      it 'should allow any zip length' do
        loc.assign_attributes zip: '123456-789'
        loc.valid?.must_equal false
        loc.assign_attributes in_germany: false
        loc.valid?.must_equal true
      end

      it 'should be okay with a missing federal_state_id' do
        loc.assign_attributes federal_state_id: nil
        loc.valid?.must_equal false
        loc.assign_attributes in_germany: false
        loc.valid?.must_equal true
      end
    end
  end

  describe '::Base' do
    describe 'associations' do
      it { subject.must have_many :offers }
      it { subject.must belong_to :organization }
      it { subject.must belong_to :federal_state }
    end
  end

  describe 'methods' do
    describe '#generate_display_name' do
      before do
        loc.assign_attributes street: 'street',
                              zip: 'zip',
                              city_id: 1,         # fixture City
                              organization_id: 1  # fixture Orga
      end

      it 'should show the basic info if nothing else exists' do
        loc.display_name.must_be_nil
        loc.generate_display_name
        loc.display_name.must_equal 'foobar | street zip Berlin'
      end

      it 'should show the location name if one exists' do
        loc.name = 'name'
        loc.generate_display_name
        loc.display_name.must_equal 'foobar, name | street zip Berlin'
      end

      it 'should show the addition if one exists' do
        loc.addition = 'addition'
        loc.generate_display_name
        loc.display_name.must_equal 'foobar | street, addition, zip Berlin'
      end

      it 'should show name & addition if both exist' do
        loc.name = 'name'
        loc.addition = 'addition'
        loc.generate_display_name
        loc.display_name.must_equal 'foobar, name | street, addition, zip Berlin'
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

  describe 'Observer' do
    it 'should call index on approved offers after visible change' do
      loc = locations(:basic)
      Offer.approved.any_instance.expects :index!
      loc.visible = !loc.visible
      loc.save!
    end
  end
end
