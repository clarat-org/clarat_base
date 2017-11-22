require_relative '../test_helper'

describe Division do
  let(:division) { divisions(:basic) }
  subject { division }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :addition }
    it { subject.must_respond_to :created_at }
    it { subject.must_respond_to :updated_at }
    it { subject.must_respond_to :label }
  end

  describe '::Base' do
    describe 'associations' do
      it { subject.must belong_to :section }
      it { subject.must belong_to :city }
      it { subject.must belong_to :area }
      it { subject.must belong_to :organization }
      it { subject.must have_many(:offers).through :offer_divisions }
    end
  end

  describe 'offers' do
    before do
      subject.offers << offers(:basic)
      @offer = subject.offers.first
      @offer_division = subject.offer_divisions.first
      subject.destroy
    end

    it 'will destroy division offers' do
      assert_raises(ActiveRecord::RecordNotFound) do
        @offer_division.reload
      end
    end

    it 'will not destroy offers' do
      refute_nil @offer.reload
    end
  end

  describe 'presumed_tags' do
    before do
      subject.presumed_tags << tags(:basic)
      @tag = subject.presumed_tags.first
      @division_tag = subject.divisions_presumed_tags.first
      subject.destroy
    end

    it 'will destroy divisions tags' do
      assert_raises(ActiveRecord::RecordNotFound) do
        @division_tag.reload
      end
    end

    it 'will not destroy offers' do
      refute_nil @tag.reload
    end
  end

  describe 'presumed_solution_categories' do
    before do
      subject.presumed_solution_categories << solution_categories(:basic)
      @sc = subject.presumed_solution_categories.first
      @division_sc = subject.divisions_presumed_solution_categories.first
      subject.destroy
    end

    it 'will destroy divisions tags' do
      assert_raises(ActiveRecord::RecordNotFound) do
        @division_sc.reload
      end
    end

    it 'will not destroy offers' do
      refute_nil @sc.reload
    end
  end
end
