# Scenario B: Svelte DataForm with inline blocks for one/nested.
# Mirrors Admin::EventForm from leadwithcharacter.
class WorkshopForm < ApplicationForm
  field :id, write: false
  field :title
  field :slug
  field :start_date
  field :end_date
  field :category
  field :status
  field :hidden
  field :max_capacity

  one :description do
    field :markdown
  end

  one :pricing_info do
    field :markdown
  end

  nested :materials, allow_destroy: true do
    field :id
    field :name
    field :quantity
    field :unit_cost
    field :hidden
  end

  def options = {categories: object.category_options}
end
