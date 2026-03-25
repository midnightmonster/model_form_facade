class ContactSubmission < ApplicationRecord
  validates :first_name, :last_name, :email, presence: true
  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP, message: "is not a valid email address"}, if: -> { email.present? }
end
