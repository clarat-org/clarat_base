require_relative '../test_helper'

describe SolutionCategory do
  let(:category) { SolutionCategory.new }

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
end
