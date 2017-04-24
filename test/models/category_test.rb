require_relative '../test_helper'

describe Category do
  let(:category) { Category.new }

  subject { category }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :name_de }
    it { subject.must_respond_to :name_en }
    it { subject.must_respond_to :name_ar }
    it { subject.must_respond_to :name_tr }
    it { subject.must_respond_to :name_fr }
    it { subject.must_respond_to :name_pl }
    it { subject.must_respond_to :name_ru }
    it { subject.must_respond_to :name_fa }
    it { subject.must_respond_to :created_at }
    it { subject.must_respond_to :updated_at }
  end

  describe 'validations' do
    describe 'always' do
      it { subject.must validate_presence_of :name_de }
      it { subject.must validate_presence_of :name_en }
      it 'must validate the presence of a section' do
        category.expects(:validate_section_presence)
        category.save
      end
      it 'must validate the sections of the parent' do
        category.expects(:validate_sections_with_parent)
        category.save
      end
    end
  end

  describe 'scopes' do
    describe 'in_section' do
      it 'should scope to a specific section filter' do
        Category.in_section('family').count.must_equal 3 # from fixtures
        Category.in_section('refugees').count.must_equal 2 # from fixtures
      end
    end
  end

  describe '::Base' do
    describe 'associations' do
      it { subject.must have_many :categories_offers }
      it { subject.must have_many(:offers).through :categories_offers }
      it { subject.must have_many(:organizations).through :offers }
      it { subject.must have_many(:sections).through :categories_sections }
    end
  end

  describe 'methods' do
    describe '#name' do
      it 'should show name_[locale] for the current locale' do
        locale = I18n.available_locales.sample
        subject.send("name_#{locale}=", 'foobar')
        I18n.with_locale(locale) do
          subject.name.must_equal 'foobar'
        end
      end

      it 'should fall back to the en locale when the current one is empty' do
        subject.name_de = 'foo'
        subject.name_en = 'bar'
        subject.name_ar = ''
        I18n.with_locale(:ar) { subject.name.must_equal('bar') }
      end

      it 'should fall back to de locale when the current one & en are empty' do
        subject.name_de = 'foo'
        subject.name_en = ''
        subject.name_ar = nil
        I18n.with_locale(:ar) { subject.name.must_equal('foo') }
      end
    end
    describe '#validate_section_presence' do
      it 'should fail when there is no section filter' do
        category.validate_section_presence
        category.wont_be :valid?
      end
      it 'should succeed when there is at least one section filter' do
        category = categories(:main1)
        category.validate_section_presence
        category.must_be :valid?
      end
    end
    describe '#validate_sections_with_parent' do
      it 'should fail when the parent does not have the section filter' do
        category = categories(:sub1)
        category.parent = categories(:main2)
        category.validate_sections_with_parent
        category.wont_be :valid?
      end
      it 'should succeed when the parent has the same section filter' do
        category = categories(:sub2)
        category.expects(:fail_validation).never
        category.validate_sections_with_parent
      end
      it 'should succeed on main categories (no parent)' do
        category = categories(:main1)
        category.expects(:fail_validation).never
        category.validate_sections_with_parent
      end
    end
  end
end
