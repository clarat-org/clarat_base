require_relative '../test_helper'

describe Opening do
  let(:opening) do
    Opening.new(
      name: 'mon 00:00-01:00',
      day: 'mon',
      open: Time.zone.now,
      close: Time.zone.now + 1.hour
    )
  end

  subject { opening }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :day }
    it { subject.must_respond_to :open }
    it { subject.must_respond_to :close }
    it { subject.must_respond_to :sort_value }
    it { subject.must_respond_to :created_at }
    it { subject.must_respond_to :updated_at }
  end

  describe '::Base' do
    describe 'associations' do
      it { subject.must have_and_belong_to_many :offers }
    end
  end

  describe 'methods' do
    describe '#appointment?' do
      it 'should return false if opening and closing hour is present' do
        opening.appointment?.must_equal false
      end

      it 'should return true if neither open nor close is present' do
        opening_new = Opening.new(day: 'mon')
        opening_new.save
        opening_new.name.must_include 'appointment'
        opening_new.appointment?.must_equal true
      end
    end
  end
end
