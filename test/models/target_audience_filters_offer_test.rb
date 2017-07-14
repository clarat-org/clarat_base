require_relative '../test_helper'

describe TargetAudienceFiltersOffer do
  let(:target_audience_filters_offer) { TargetAudienceFiltersOffer.new }
  subject { target_audience_filters_offer }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :target_audience_filter_id }
    it { subject.must_respond_to :offer_id }
    it { subject.must_respond_to :residency_status }
    it { subject.must_respond_to :gender_first_part_of_stamp }
    it { subject.must_respond_to :gender_second_part_of_stamp }
    it { subject.must_respond_to :age_from }
    it { subject.must_respond_to :age_to }
    it { subject.must_respond_to :age_visible }
    it { subject.must_respond_to :stamp_de }
    it { subject.must_respond_to :stamp_en }
    it { subject.must_respond_to :stamp_ar }
    it { subject.must_respond_to :stamp_fa }
    it { subject.must_respond_to :stamp_fr }
    it { subject.must_respond_to :stamp_tr }
    it { subject.must_respond_to :stamp_ru }
    it { subject.must_respond_to :stamp_pl }
  end

  describe '::Base' do
    describe 'associations' do
      it { subject.must belong_to(:offer) }
      it { subject.must belong_to(:target_audience_filter) }
    end
  end
end
