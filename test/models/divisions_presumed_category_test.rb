require_relative '../test_helper'

describe DivisionsPresumedCategory do
  subject { DivisionsPresumedCategory.new }

  describe 'relations' do
    it { subject.must belong_to :category }
    it { subject.must belong_to :division }
  end
end
