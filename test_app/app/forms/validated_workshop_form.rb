# Scenario E: Form-level validations on top of model validations.
# Demonstrates the interaction between ActiveModel::Validations on the form
# and object.errors.messages from the model.
class ValidatedWorkshopForm < RecordForm
  validates :title, length: {minimum: 5, message: "must be at least 5 characters"}
  validates :slug, format: {with: /\A[a-z0-9-]+\z/, message: "only lowercase letters, numbers, and hyphens"}, if: -> { slug.present? }

  field :title
  field :slug
  field :category
  field :status

  nested :materials, allow_destroy: true do
    field :id
    field :name
    field :quantity
  end

  def options = {categories: object.category_options}

  def model_name = object.model_name

  private

  def _params_root(root: nil)
    case root.nil? ? params_root : root
    in true then :workshop
    in false then nil
    in Symbol => sym then sym
    in String => str then str.to_sym
    end
  end
end
