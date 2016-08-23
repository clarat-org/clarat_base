require_relative '../test_helper'

describe City do
  let(:city) { City.new }

  subject { city }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :name }
    it { subject.must_respond_to :created_at }
    it { subject.must_respond_to :updated_at }
  end

  describe 'validations' do
    describe 'always' do
      it { subject.must validate_presence_of :name }
      it { subject.must validate_uniqueness_of :name }
    end
  end

  describe '::Base' do
    describe 'associations' do
      it { subject.must have_many :locations }
      it { subject.must have_many(:offers).through :locations }
      it { subject.must have_many(:organizations).through :locations }
    end
  end
end
