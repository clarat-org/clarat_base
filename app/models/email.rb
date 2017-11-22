# A unique email address
class Email < ApplicationRecord
  include AASM

  attr_accessor :given_security_code

  # Associations
  has_many :contact_people, inverse_of: :email, dependent: :nullify
  has_many :offers, -> { distinct },
           through: :contact_people,
           inverse_of: :emails
  has_many :organizations, -> { distinct }, through: :contact_people,
                                            inverse_of: :emails

  # Validations moved to claradmin
  FORMAT = /\A\S+@\S+\.\S+\z/

  # State Machine
  aasm do
    state :uninformed, initial: true # E-Mail was created, owner doesn't know
    state :informed # An offer has been approved
    state :subscribed # Email recipient has subscribed to further updates
    state :unsubscribed # Email recipient was subscribed but is no longer
    state :blocked # Email is blocked from receiving mailings

    event :subscribe, guard: :security_code_confirmed? do
      transitions from: :informed, to: :subscribed
      transitions from: :unsubscribed, to: :subscribed
    end

    event :unsubscribe do
      transitions from: :subscribed, to: :unsubscribed
    end
  end

  # Methods

  def security_code_confirmed?
    given_security_code == security_code
  end

  private

  def regenerate_security_code
    self.security_code = SecureRandom.uuid
  end

  def should_be_blocked?
    contact_people.where(spoc: true).any?
  end
end
