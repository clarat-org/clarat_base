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

    it 'must destroy associated assignments when assignable is destroyed' do
      subject.assignments.count.must_equal 1
      subject.assignments.first.close!
      new_assignment = Assignment.create!(
        assignable: subject, assignable_type: subject.class.name,
        creator_id: 1, creator_team_id: 1, receiver_id: 2,
        receiver_team_id: 2, message: 'TestMessage'
      )
      subject.assignments.count.must_equal 2
      # check if data is persisted
      subject.persisted?.must_equal true
      assignment.persisted?.must_equal true
      new_assignment.persisted?.must_equal true
      # destroy offer => destroys all translations => destroys all assignments
      subject.offer.destroy!
      # record lookups fail => everything is destroyed
      assert_raises(ActiveRecord::RecordNotFound) { subject.reload }
      assert_raises(ActiveRecord::RecordNotFound) { assignment.reload }
      assert_raises(ActiveRecord::RecordNotFound) { new_assignment.reload }
    end
  end

  describe 'current_assignment' do
    it 'finds the newest active base association without a parent' do
      model = Organization.first
      Assignment.create(
        assignable: model, aasm_state: 'open', message: 'earlier decoy'
      )
      correct_assignment = Assignment.create(
        assignable: model, aasm_state: 'open', message: 'correct'
      )
      Assignment.create(
        assignable: model, aasm_state: 'closed', message: 'closed decoy'
      )
      Assignment.create(
        assignable: model, aasm_state: 'open', assignable_field_type: 'name',
        message: 'non-base decoy'
      )
      Assignment.create(
        assignable: model, aasm_state: 'open', parent: correct_assignment,
        message: 'child decoy'
      )
      Assignment.create(
        assignable: Division.first, aasm_state: 'open',
        message: 'other assignable decoy'
      )
      model.reload.current_assignment.must_equal correct_assignment
    end

    it 'should be able to eager_load' do
      assignment = Assignment.create!(
        assignable_type: 'Division', assignable_id: Division.first.id,
        message: 'whatever', topic: 'new', receiver_id: User.first.id,
        creator_id: User.first.id
      )
      result = Division.eager_load(:current_assignment)
                       .where('assignments.id = ?', assignment.id).first
      result.class.must_equal Division
      result.current_assignment.must_equal assignment
    end
  end

  # describe 'methods' do
  #   describe '#current_assignment' do
  #     it 'must return the current assignment' do
  #       subject.current_assignment.must_equal assignment
  #     end
  #   end
  #
  #   describe '#field_assignments' do
  #     it 'must return connected field assignments' do
  #       subject.field_assignments.must_equal []
  #       field_assignment1 = FactoryGirl.create :assignment, :with_field, assignable: subject
  #       field_assignment2 = FactoryGirl.create :assignment, :with_field, assignable: subject
  #       subject.field_assignments.must_equal [field_assignment1, field_assignment2]
  #     end
  #   end
  #
  #   describe '#current_field_assignment' do
  #     it 'must return current field assignment' do
  #       field_assignment = FactoryGirl.create :assignment, :with_field, assignable: subject
  #       subject.current_field_assignment(:id).must_equal field_assignment
  #     end
  #
  #     it 'must return current base assignment if there is none for the field' do
  #       subject.current_field_assignment(:id).must_equal assignment
  #     end
  #
  #     it 'must correctly handle the state of the assignment' do
  #       field_assignment = FactoryGirl.create :assignment, :with_field, assignable: subject, aasm_state: 'closed'
  #       subject.current_field_assignment(:id).must_equal assignment
  #       field_assignment.update_column :aasm_state, 'open'
  #       subject.current_field_assignment(:id).must_equal field_assignment
  #     end
  #
  #     it 'must return nil for non-existing fields' do
  #       assert_nil subject.current_field_assignment(:doesNotExist)
  #     end
  #   end
  #
  #   describe '#create_new_assignment!' do
  #     it 'must close current assignment and create a new one' do
  #       subject.current_assignment.must_equal assignment
  #       subject.assignments.count.must_equal 1
  #       subject.assignments.closed.count.must_equal 0
  #       new_assignment = subject.create_new_assignment!(1, 1, 2, 2, 'New Assignment!')
  #       subject.assignments.count.must_equal 2
  #       subject.assignments.closed.count.must_equal 1
  #       subject.current_assignment.must_equal new_assignment
  #     end
  #   end
  # end
end
