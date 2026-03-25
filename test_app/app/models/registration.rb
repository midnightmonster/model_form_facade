class Registration < ApplicationRecord
  CONTACT_ATTRIBUTES = %w[first_name last_name email phone].freeze

  belongs_to :workshop
  has_many :attendees, dependent: :destroy

  accepts_nested_attributes_for :attendees, allow_destroy: true

  validates :email, presence: true
end
