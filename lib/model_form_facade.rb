require_relative "model_form_facade/version"
require "active_support"

module ModelFormFacade
  class Error < StandardError; end

  extend ActiveSupport::Concern

  included do
    class_attribute :fields, instance_accessor: false, instance_predicate: false, default: {}
    class_attribute :params_root, default: true # infer from model
    attr_reader :object
    private attr_writer :object
    private attr_accessor :component_props
  end

  def initialize(model_object = nil, root: nil, **component_props)
    self.params_root = root unless root.nil?
    self.object = model_object
    self.component_props = component_props
  end

  def options = {} # Override me

  def as_json(root: params_root)
    hash = self.class.fields.values.filter_map do |field|
      next nil unless field.read

      raw = send(field.name)
      value = case field.type
      in :scalar then raw
      in :object then field.form.new(raw).as_json(root: false)
      in :array then (raw || []).map { field.form.new(_1).as_json(root: false) }
      end
      [field.name, field.serialize(value)]
    end.to_h.compact
    return hash unless (root = _params_root(root:))
    {root => hash}
  end

  def errors(root: params_root)
    errs = object_error_messages.reject { |k, v| k.to_s.include? "." } # Remove nested, we'll recurse
    hash = self.class.fields.values.filter_map do |field|
      err = case field.type
      in :scalar then errs[field.attribute]&.map(&:capitalize)&.join(";").presence
      in :object then field.form.new(send(field.name)).errors(root: false)
      in :array then (send(field.name) || []).map { field.form.new(_1).errors(root: false) }
      end
      [field.name, err] if err
    end.to_h.compact
    return hash unless (root = _params_root(root:))
    {root => hash}
  end

  def form_props(root: params_root)
    {
      **component_props,
      data: as_json(root:),
      options: options,
      errors: errors(root:)
    }
  end

  def set_fields(params, root: nil)
    params = params.expect(expectation(root:)) if params.respond_to?(:expect) && !params.permitted?
    self.attributes = params
  end
  alias_method :fields=, :set_fields

  def attributes=(hash)
    hash.each do |key, value|
      send("#{key}=", value)
    end
  end

  def attributes = as_json

  def expectation(root: nil)
    self.class.expectation(root: _params_root(root:))
  end

  def save! = object.save!

  def save = object.save

  private def _params_root(root: nil)
    case root.nil? ? params_root : root
    in true then object.class.name&.split("::")&.last&.downcase&.to_sym
    in false then nil
    in Symbol => sym then sym
    in String => str then str.to_sym
    end
  end

  private def object_error_messages = object&.errors&.messages || {}

  Field = Data.define(:name, :read, :write, :attribute, :type, :form) do
    def serialize(v)
      return v unless type == :scalar
      v&.to_s
    end
  end

  module FieldMethods; end

  class_methods do
    def field(name, read: nil, write: nil, attribute: nil)
      _field(name, read:, write:, attribute:, type: :scalar)
    end

    def one(*, **, &block) = _relation(*, **, type: :object, &block)

    def nested(*, **, &block) = _relation(*, **, type: :array, &block)

    def expectation(root:)
      expected = fields.values.select(&:write).map do |field|
        case field.type
        in :scalar then field.name
        in :object then {field.name => field.form.expectation(root: false)}
        in :array then {field.name => [field.form.expectation(root: false)]}
        end
      end
      return expected unless root &&= root.to_sym
      {root => expected}
    end

    private

    def _relation(name, allow_destroy: false, form: nil, read: nil, write: nil, attribute: nil, type: nil, &block)
      form ||= create_form_class_for(name)
      form.field :_destroy, read: false if allow_destroy
      form.instance_exec(&block) if block
      if write.nil? && attribute.nil? && !name.to_s.ends_with?("_attributes")
        write = :"#{name}_attributes="
      end
      _field(name, read:, write:, attribute:, type:, form:)
    end

    def _field(name, read: nil, write: nil, attribute: nil, type: :scalar, form: nil)
      name = name.to_sym
      attribute = (attribute || name).to_sym
      read = attribute if read.nil?
      write = :"#{attribute}=" if write.nil?
      field = Field.new(name:, read:, write:, attribute:, type:, form:)
      self.fields = {**fields, name.to_sym => field}
      field_methods_module.define_method(name) { object&.send(read) } unless read == false
      field_methods_module.define_method(:"#{name}=") { |value| object.send(write, value) } unless write == false
    end

    def create_form_class_for(field_name)
      class_name = "anonymous_#{field_name}_form".camelize
      const_set(class_name, Class.new.tap { _1.include ModelFormFacade })
    end

    def field_methods_module
      return @field_methods_module if @field_methods_module
      @field_methods_module = Module.new
      module_name = name.presence && name.gsub(/\W+/, "__") + "Fields"
      FieldMethods.const_set(module_name, @field_methods_module) if module_name
      include @field_methods_module
      @field_methods_module
    end
  end
end
