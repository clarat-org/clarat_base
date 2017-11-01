require_relative '../test_helper'

describe DivisionsPresumedTag do
  subject { DivisionsPresumedTag.new }

  describe 'relations' do
    it { subject.must belong_to :tag }
    it { subject.must belong_to :division }
  end
end
