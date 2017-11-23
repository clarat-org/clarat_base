require_relative '../test_helper'

describe ContactPerson do
  let(:contact_person) { contact_people(:basic) }

  subject { contact_person }

  describe 'attributes' do
    it { subject.must_respond_to :first_name }
    it { subject.must_respond_to :last_name }
    it { subject.must_respond_to :label }
    it { subject.must_respond_to :operational_name }
    it { subject.must_respond_to :academic_title }
    it { subject.must_respond_to :gender }
    it { subject.must_respond_to :responsibility }
    it { subject.must_respond_to :area_code_1 }
    it { subject.must_respond_to :local_number_1 }
    it { subject.must_respond_to :area_code_2 }
    it { subject.must_respond_to :local_number_2 }
    it { subject.must_respond_to :fax_area_code }
    it { subject.must_respond_to :fax_number }
    it { subject.must_respond_to :email_id }
    it { subject.must_respond_to :spoc } # SPoC = Single Point of Contact
    it { subject.must_respond_to :position }
    it { subject.must_respond_to :street }
    it { subject.must_respond_to :zip_and_city }
  end

  describe '::Base' do
    describe 'associations' do
      it { subject.must belong_to :organization }
      it { subject.must belong_to :email }
      it { subject.must have_many :contact_person_offers }
      it { subject.must have_many(:offers).through :contact_person_offers }
    end
  end

  describe 'contact people' do
    it 'sets email_id to nil if email gets deleted' do
      email = Email.new
      contact_person.email_id = email.id
      email.destroy
      contact_person.email_id.must_equal nil
    end
  end

  describe 'methods' do
    describe '#telephone_#{n}' do
      it 'should return the concatenated area code and local number' do
        contact_person.assign_attributes area_code_1: '0', local_number_1: '1',
                                         area_code_2: '2', local_number_2: '3'
        contact_person.telephone_1.must_equal '01'
        contact_person.telephone_2.must_equal '23'
      end
    end

    describe '#fax' do
      it 'should return the concatenated fax area code and fax number' do
        contact_person.assign_attributes fax_area_code: '4', fax_number: '5'
        contact_person.fax.must_equal '45'
      end
    end

    describe 'offers' do
      before do
        @offer = offers(:basic)
        contact_person.offers << @offer
        @contact_person_offer = contact_person.contact_person_offers.first
        contact_person.destroy
      end

      it 'will destroy contact person offers' do
        assert_raises(ActiveRecord::RecordNotFound) do
          @contact_person_offer.reload
        end
      end

      it 'will not destroy offers' do
        refute_nil @offer.reload
      end
    end
  end
end
