# Scenario C: Svelte DataForm with custom assign_attributes (buffer-and-transform).
# Mirrors RegistrationForm from leadwithcharacter.
class RegistrationForm < ApplicationForm
  one :primary_attendee, form: AttendeeForm
  nested :additional_attendees, form: AttendeeForm, allow_destroy: true

  # Buffer writes and copy contact details from primary attendee to registration
  attr_writer :primary_attendee, :additional_attendees

  def assign_attributes(...)
    super.tap do
      # Copy contact details from primary attendee to registration
      object.attributes = @primary_attendee.slice(*Registration::CONTACT_ATTRIBUTES)
      # Combine attendees and set attendees_attributes
      attendees = [@primary_attendee, *@additional_attendees&.values]
      attendees.each_with_index { |a, i| a["sort_order"] = i unless a["_destroy"].present? }
      object.attendees_attributes = attendees
    end
  end

  def options = {
    workshops: Workshop.pluck(:title, :id)
  }
end
