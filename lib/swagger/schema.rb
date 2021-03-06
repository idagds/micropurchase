class Swagger::Schema
end

require_relative 'mixins/description'
require_relative 'schema/all_of'
require_relative 'schema/boolean'
require_relative 'schema/number'
require_relative 'schema/string'
require_relative 'schema/array'
require_relative 'schema/object'

class Swagger::Schema
  include Swagger::Mixins::Description

  attr_accessor :fields

  def initialize(name, fields, specification)
    @fields = fields.merge('name' => name)
    @specification = specification
  end

  def default
    fields['default']
  end

  def description
    fields['description']
  end

  def enum
    fields['enum']
  end

  def format
    fields['format']
  end

  def name
    fields['name']
  end

  def nullable
    fields['nullable']
  end

  def title
    fields['title']
  end

  def type
    fields['type']
  end

  def unique_key
    "definition-#{name}"
  end

  def comment
    fields['x-comment']
  end

  def sample_value
    if fields.key?('example')
      fields['example'].inspect
    elsif fields.key?('enum')
      fields['enum'].first.inspect
    else
      default_sample_value
    end
  end

  def property_json_line
    "  \"#{name}\": #{sample_value}".html_safe
  end

  def self.factory(name, fields, specification)
    if fields.key?('$ref')
      Swagger::Reference.new(name, fields, specification)
    elsif fields.key?('allOf')
      Swagger::Schema::AllOf.new(name, fields, specification)
    else
      case fields['type']
      when ::Array
        if fields['type'].size == 2 && fields['type'].last == 'null'
          factory(name, fields.merge('nullable' => true, 'type' => fields['type'].first), specification)
        else
          fail "Unhandled array type: #{fields.inspect}"
        end
      when 'string'
        Swagger::Schema::String.new(name, fields, specification)
      when 'integer', 'number', 'boolean'
        Swagger::Schema::Number.new(name, fields, specification)
      when 'boolean'
        Swagger::Schema::Boolean.new(name, fields, specification)
      when 'array'
        Swagger::Schema::Array.new(name, fields, specification)
      when 'object', nil
        Swagger::Schema::Object.new(name, fields, specification)
      else
        fail "Unhandled property type: #{fields.inspect}"
      end
    end
  end
end
