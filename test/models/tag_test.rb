require_relative '../test_helper'

describe Tag do
  let(:tag) { Tag.new }

  subject { tag }

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
    it { subject.must_respond_to :keywords_de }
    it { subject.must_respond_to :keywords_en }
    it { subject.must_respond_to :keywords_ar }
    it { subject.must_respond_to :keywords_fa }
    it { subject.must_respond_to :created_at }
    it { subject.must_respond_to :updated_at }
    it { subject.must_respond_to :explanations_de }
    it { subject.must_respond_to :explanations_en }
    it { subject.must_respond_to :explanations_ar }
    it { subject.must_respond_to :explanations_fa }
  end

  describe 'validations' do
    describe 'always' do
      it { subject.must validate_presence_of :name_de }
      it { subject.must validate_presence_of :name_en }
      it { subject.must validate_length_of(:explanations_de).with_maximum(500) }
      it { subject.must validate_length_of(:explanations_en).with_maximum(500) }
      it { subject.must validate_length_of(:explanations_ar).with_maximum(500) }
      it { subject.must validate_length_of(:explanations_fa).with_maximum(500) }
    end
  end

  describe '::Base' do
    describe 'associations' do
      it { subject.must have_many :tags_offers }
      it { subject.must have_many(:offers).through :tags_offers }
    end
  end
end