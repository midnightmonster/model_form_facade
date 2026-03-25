# ModelFormFacade

Form objects as read/write facades for your models, with a convenient DSL.

ModelFormFacade lets you define form classes that expose a controlled subset of a model's fields (and its associations) for use with Rails form helpers or JSON serialization. Each form declares which fields are readable, writable, or both, and handles Strong Parameters, nested attributes, and error collection automatically.

## Installation

Add to your Gemfile:

```ruby
gem "model_form_facade"
```

## Usage

### Basic form with scalar fields

```ruby
class RecordForm
  include ModelFormFacade
  include ActiveModel::Validations
end

class ContactForm < RecordForm
  validates :email, presence: true

  field :first_name
  field :last_name
  field :email
  field :phone
end
```

In a controller:

```ruby
def update
  form = ContactForm.new(Contact.find(params[:id]))
  form.set_fields(params)   # applies Strong Parameters, then assigns
  form.save!
  redirect_to contacts_path
rescue ActiveRecord::RecordInvalid
  render :edit, status: :unprocessable_entity
end
```

With `form_with` in a view:

```erb
<%= form_with model: form, url: contact_path(form.object) do |f| %>
  <%= f.text_field :first_name %>
  <%= f.email_field :email %>
  <%= f.submit %>
<% end %>
```

### Nested associations

Use `one` for a single child and `nested` for a collection. Define fields inline with a block, or pass an explicit `form:` class.

```ruby
class EventForm
  include ModelFormFacade

  field :id, write: false    # read-only
  field :title
  field :status

  one :description do         # inline — auto-creates a form class
    field :markdown
  end

  nested :tickets, allow_destroy: true do
    field :id
    field :name
    field :price
  end

  def options = { statuses: [["Draft", "draft"], ["Published", "published"]] }
end
```

`one` maps to `description_attributes=` and `nested` maps to `tickets_attributes=` on the model (via `accepts_nested_attributes_for`). Pass `allow_destroy: true` to include the `_destroy` flag.

You can also pass an explicit form class:

```ruby
class AttendeeForm
  include ModelFormFacade

  field :id
  field :first_name
  field :last_name
  field :email
end

class RegistrationForm
  include ModelFormFacade

  one :primary_attendee, form: AttendeeForm
  nested :additional_attendees, form: AttendeeForm, allow_destroy: true
end
```

### Custom read/write accessors

Override the generated reader or writer to transform data:

```ruby
class AddressForm
  include ModelFormFacade

  field :line1
  field :city
  field :source_record, write: false   # disable generated writer

  # Custom getter: JSONB column → JSON string for form display
  def source_record = object.source_record&.to_json

  # Custom setter: JSON string → parsed hash
  def source_record=(v)
    object.source_record = (JSON.parse(v) rescue nil)
  end
end
```

### Write guards and read-only fields

```ruby
class PageForm
  include ModelFormFacade

  field :id, write: false
  field :name
  field :system, write: false          # exposed for display but not writable

  one :rich_content do
    field :markdown
  end

  def system = object.system? ? "true" : ""

  def name=(...)
    return if object.system?           # guard: don't allow renaming system pages
    super
  end
end
```

### JSON serialization

`as_json`, `errors`, and `form_props` serialize the form for use with JavaScript form libraries:

```ruby
form = EventForm.new(event)

form.as_json(root: false)
# => { title: "Pasta Making", status: "published", description: { markdown: "..." }, tickets: [...] }

form.errors(root: false)
# => { title: "can't be blank" }

form.form_props
# => { data: { event: { ... } }, options: { statuses: [...] }, errors: { event: { ... } } }
```

### Custom assign_attributes

Override `assign_attributes` when you need to buffer or transform values before they hit the model (rare):

```ruby
class RegistrationForm
  include ModelFormFacade

  one :primary_attendee, form: AttendeeForm
  nested :additional_attendees, form: AttendeeForm, allow_destroy: true

  attr_writer :primary_attendee, :additional_attendees

  def assign_attributes(...)
    super.tap do
      object.attributes = @primary_attendee.slice("first_name", "last_name", "email")
      object.attendees_attributes = [@primary_attendee, *@additional_attendees&.values]
    end
  end
end
```

## API Reference

### DSL (class methods)

| Method | Description |
|---|---|
| `field :name, read:, write:, attribute:` | Declare a scalar field. `read: false` hides it from serialization; `write: false` makes it read-only. |
| `one :name, form:, allow_destroy:, &block` | Declare a single nested object (maps to `name_attributes=`). |
| `nested :name, form:, allow_destroy:, &block` | Declare a collection of nested objects (maps to `name_attributes=`). |

### Instance methods

| Method | Description |
|---|---|
| `set_fields(params, root:)` | Apply Strong Parameters and assign to fields. |
| `assign_attributes(hash)` | Assign a hash directly to fields (no Strong Parameters). |
| `as_json(root:)` | Serialize readable fields to a hash. |
| `errors(root:)` | Collect model validation errors into a hash matching the form structure. |
| `form_props(root:)` | Returns `{ data:, options:, errors:, **component_props }`. |
| `save` / `save!` | Delegate to the underlying model. |
| `object` | The wrapped model instance. |

## Development

The repo includes a full Rails app in `test_app/` that exercises every feature of the gem across five scenarios:

| Scenario | Route | What it demonstrates |
|---|---|---|
| HTML form | `/contact` | `form_with`, form-level validations, conditional save |
| Inline blocks | `/workshops` | `one` / `nested` with block DSL, `options`, model validations |
| Custom assign | `/registrations` | Explicit form classes, `assign_attributes` override, buffer-and-transform |
| Read-only / guards | `/pages` | `write: false`, custom setter guards |
| Dual validations | `/validated_workshops` | Form-level + model-level validations |

### Running the test app

```bash
cd test_app
bundle install
npm install
bin/rails db:create db:migrate db:seed
overmind start          # Rails on :3100, Vite on :3101
```

Then visit http://localhost:3100.

The test app references the gem via `path: "../.."`, so changes to `lib/` are picked up immediately on the next request.

### Running the gem's tests

```bash
bundle install
rake test
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
