class Attendee < ApplicationRecord
  belongs_to :registration

  validates :first_name, :last_name, presence: true
end
