require_relative '../test_helper'

describe SolutionCategory do
  let(:category) { solution_categories(:basic) }

  subject { category }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :name }
    it { subject.must_respond_to :parent_id }
    it { subject.must_respond_to :created_at }
    it { subject.must_respond_to :updated_at }
  end

  describe 'associations' do
    it { subject.must have_many(:offers) }
    it { subject.must have_many(:divisions_presumed_solution_categories) }
    it { subject.must have_many(:presuming_divisions) }
  end

  describe 'offers' do
    before do
      offer = offers(:basic)
      subject.offers << offer
    end

    it 'should not delete solution category' do
      assert_raises(ActiveRecord::DeleteRestrictionError) { subject.destroy }
    end

    it 'should delete solution category when there is no offer' do
      subject.offers.destroy_all
      subject.destroy
      assert_raises(ActiveRecord::RecordNotFound) { subject.reload }
    end
  end
end
