# Scenario D: Read-only fields, write guards.
# Mirrors Admin::ContentForm from leadwithcharacter.
class PageForm < ApplicationForm
  field :id, write: false
  field :name
  field :system, write: false

  one :rich_content do
    field :markdown
  end

  def system = object.system? ? "true" : ""

  def name=(...)
    return if object.system?
    super
  end
end
