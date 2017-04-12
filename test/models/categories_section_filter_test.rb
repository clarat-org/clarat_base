require 'test_helper'

class CategoriesSectionFilterTest < ActiveSupport::TestCase

  let(:categories_section_filter) { categories_section_filters(:one) }

  subject { categories_section_filter }

  describe '::Base' do
    describe 'associations' do
      it { subject.must belong_to :category }
      it { subject.must belong_to :section_filter }
    end
  end

end
