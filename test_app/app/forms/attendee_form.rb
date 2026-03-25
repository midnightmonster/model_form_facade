# Explicit nested form class for attendees. Custom getter/setter for metadata (JSONB).
# Mirrors AddressForm from jlg-portal-uk.
class AttendeeForm < ApplicationForm
  field :id
  field :first_name
  field :last_name
  field :email
  field :phone
  field :dietary_requirements
  field :age

  # Custom getter/setter: JSON string <-> hash (like AddressForm.source_record)
  field :metadata, write: false

  def metadata = object.metadata&.to_json

  def metadata=(v)
    object.metadata = (JSON.parse(v) rescue nil)
  end
end
