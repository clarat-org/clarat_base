require_relative '../test_helper'

describe SplitBase do
  let(:split_base) { SplitBase.new }
  subject { split_base }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :title }
    it { subject.must_respond_to :clarat_addition }
    it { subject.must_respond_to :comments }
    it { subject.must_respond_to :created_at }
    it { subject.must_respond_to :updated_at }
  end

  describe 'validations' do
    describe 'always' do
      it { split_base.must validate_presence_of :title }
      it { split_base.must validate_presence_of :solution_category_id }

      it 'should validate the uniqueness between different fields' do
        existing_attrs = {
          title: 'a', clarat_addition: 'a', solution_category_id: 1
        }
        SplitBase.create! existing_attrs
        split_base.assign_attributes existing_attrs
        split_base.valid?.must_equal false
        split_base.errors.messages.length.must_equal 3
        split_base.errors.messages[existing_attrs.keys.sample][0].must_equal(
          'has already been taken'
        )

        split_base.title = 'new'
        split_base.valid?.must_equal true

        split_base.title = existing_attrs[:title]
        split_base.clarat_addition = 'new'
        split_base.valid?.must_equal true

        split_base.clarat_addition = existing_attrs[:clarat_addition]
        split_base.solution_category_id = 2
        split_base.valid?.must_equal true

        # split_base.organization_id = existing_attrs[:organization_id]
        # split_base.solution_category_id = 2
        # split_base.valid?.must_equal true

        split_base.solution_category_id = existing_attrs[:solution_category_test]
        split_base.valid?.must_equal false
      end
    end
  end

  describe 'associations' do
    it { subject.must have_many :offers }
    it { subject.must have_many(:split_base_divisions) }
    it { subject.must have_many(:divisions).through :split_base_divisions }
    it { subject.must have_many(:organizations).through :divisions }
    it { subject.must belong_to :solution_category }
  end
end
