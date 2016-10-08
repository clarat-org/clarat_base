require_relative '../test_helper'

describe Assignable do
  let(:assignment) do
    FactoryGirl.create :assignment
  end
  subject { assignment.assignable }

  describe 'basics' do
    it 'should respond to assignments' do
      subject.assignments.count.must_equal 1
      subject.assignments.first.must_equal assignment
    end
  end

  describe 'methods' do
    describe '#current_assignment' do
      it 'must return the current assignment' do
        subject.current_assignment.must_equal assignment
      end
    end

    describe '#field_assignments' do
      it 'must return connected field assignments' do
        subject.field_assignments.must_equal []
        field_assignment1 = FactoryGirl.create :assignment, :with_field, assignable: subject
        field_assignment2 = FactoryGirl.create :assignment, :with_field, assignable: subject
        subject.field_assignments.must_equal [field_assignment1, field_assignment2]
      end
    end

    describe '#current_field_assignment' do
      it 'must return current field assignment' do
        field_assignment = FactoryGirl.create :assignment, :with_field, assignable: subject
        subject.current_field_assignment(:id).must_equal field_assignment
      end

      it 'must return current base assignment if there is none for the field' do
        subject.current_field_assignment(:id).must_equal assignment
      end

      it 'must correctly handle the state of the assignment' do
        field_assignment = FactoryGirl.create :assignment, :with_field, assignable: subject, aasm_state: 'closed'
        subject.current_field_assignment(:id).must_equal assignment
        field_assignment.update_column :aasm_state, 'open'
        subject.current_field_assignment(:id).must_equal field_assignment
      end

      it 'must return nil for non-existing fields' do
        subject.current_field_assignment(:doesNotExist).must_equal nil
      end
    end

    describe '#create_new_assignment!' do
      it 'must close current assignment and create a new one' do
        subject.current_assignment.must_equal assignment
        subject.assignments.count.must_equal 1
        subject.assignments.closed.count.must_equal 0
        new_assignment = subject.create_new_assignment!(1, 1, 2, 2, 'New Assignment!')
        subject.assignments.count.must_equal 2
        subject.assignments.closed.count.must_equal 1
        subject.current_assignment.must_equal new_assignment
      end
    end

    describe '#assign_new_user_team!' do
      it 'must close current assignment and create a new one' do
        subject.current_assignment.must_equal assignment
        subject.assignments.count.must_equal 1
        subject.assignments.closed.count.must_equal 0
        new_assignment = subject.assign_new_user_team!(1, 1, 2, 'New Assignment!')
        subject.assignments.count.must_equal 2
        subject.assignments.closed.count.must_equal 1
        subject.current_assignment.must_equal new_assignment
      end
    end
  end
end
