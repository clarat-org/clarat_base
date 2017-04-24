require 'test_helper'

class CategoriesSectionTest < ActiveSupport::TestCase
  let(:categories_section) { categories_sections(:one) }

  subject { categories_section }

  describe '::Base' do
    describe 'associations' do
      it { subject.must belong_to :category }
      it { subject.must belong_to :section }
    end
  end
end
