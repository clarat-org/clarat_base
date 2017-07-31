require_relative '../test_helper'

describe Assignment do
  let(:assignment) { Assignment.new }
  subject { assignment }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :assignable }
    it { subject.must_respond_to :creator }
    it { subject.must_respond_to :creator_team }
    it { subject.must_respond_to :receiver }
    it { subject.must_respond_to :receiver_team }
    it { subject.must_respond_to :parent }
    it { subject.must_respond_to :children }
    it { subject.must_respond_to :created_at }
    it { subject.must_respond_to :updated_at }
    it { subject.must_respond_to :topic }
    it { subject.must_respond_to :created_by_system }
  end

  describe 'Scopes' do
    describe 'active' do
      it 'responds correctly to opened scope' do
        Assignment.active.count.must_equal 0
        FactoryGirl.create :organization
        Assignment.active.count.must_equal 1
        Assignment.first.update_column :aasm_state, 'closed'
        Assignment.active.count.must_equal 0
      end
    end
    describe 'closed' do
      it 'responds correctly to closed scope' do
        Assignment.closed.count.must_equal 0
        FactoryGirl.create :organization
        Assignment.closed.count.must_equal 0
        Assignment.first.update_column :aasm_state, 'closed'
        Assignment.closed.count.must_equal 1
      end
    end
    describe 'root' do
      it 'responds correctly to root scope' do
        Assignment.root.count.must_equal 0
        FactoryGirl.create :organization
        Assignment.root.count.must_equal 1
        FactoryGirl.create :organization
        Assignment.root.count.must_equal 2
        Assignment.last.update_column :parent_id, Assignment.first.id
        Assignment.root.count.must_equal 1
      end
    end
    describe 'base' do
      it 'responds correctly to base scope' do
        Assignment.base.count.must_equal 0
        FactoryGirl.create :organization
        Assignment.base.count.must_equal 1
        Assignment.first.update_column :assignable_field_type, 'SomeField'
        Assignment.base.count.must_equal 0
      end
    end
    describe 'field' do
      it 'responds correctly to field scope' do
        Assignment.field.count.must_equal 0
        FactoryGirl.create :organization
        Assignment.field.count.must_equal 0
        Assignment.first.update_column :assignable_field_type, 'SomeField'
        Assignment.field.count.must_equal 1
      end
    end
  end
end
