module DataPortal
  module View
    extend ActiveSupport::Concern

    included do
      attr_accessor :ids, :filters, :options, :source, :output

      class_attribute :attributes
      class_attribute :fields
      class_attribute :count_fields
      class_attribute :model

      self.attributes = {}
      self.fields = {}
      self.count_fields = {}

      def initialize(ids:, filters: {}, options: {})
        @ids = ids.is_a?(Array) ? ids : [ids]
        @filters = filters
        @options = options
      end

      def render
        source.is_a?(Array) ? render_many : render_one
      end

      def source
        # convention over configuration
        provider_class = "Providers::#{model.name}Provider".constantize
        @source ||= provider_class.new(
          ids: ids,
          attributes: attributes,
          fields: fields,
          model_class: model
        ).execute
      end

      def render_one
        output = {}
        render_attributes output
        render_fields output
        render_count_fields output

        output
      end

      def render_attributes(output)
        attributes.each do |name, attr|
          # TODO:
          # Handle options & default value
          output[name] = attr.value source
        end
      end

      def render_fields(output)
        fields.each do |name, field|
          # TODO:
          # Handle subfields, i.e. blocks
          # Handle default values
          output[name] = field.value source
        end
      end

      def render_count_fields(output)
        count_fields.each do |name, field|
          # TODO: Add "as:" option support
          output["#{name}_count"] = field.value source
        end
      end
    end

    module ClassMethods
      def attribute(name, options = {}, &block)
        attributes[name] = DataPortal::Attributes::Standard.new(name, options, &block)
        true
      end

      def count_field(name, _options = {})
        # TODO: Add "as: " to options
        count_fields[name] = DataPortal::Fields::Count.new(name)
        true
      end

      def field(name, options = {}, &block)
        fields[name] = DataPortal::Fields::Standard.new(name, options, &block)
        true
      end

      def model_class(klass)
        self.model = klass
        true
      end
    end
  end
end
