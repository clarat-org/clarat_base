require_relative '../test_helper'

describe DivisionsPresumedSolutionCategory do
  subject { DivisionsPresumedSolutionCategory.new }

  describe 'relations' do
    it { subject.must belong_to :solution_category }
    it { subject.must belong_to :division }
  end
end
