module DataPortal
  module View
    extend ActiveSupport::Concern

    included do
      attr_accessor :ids, :filters, :options, :source, :output

      class_attribute :attributes
      class_attribute :count_attributes
      class_attribute :model
      class_attribute :relations

      self.attributes = {}
      self.relations = {}
      self.count_attributes = {}

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
          relations: relations,
          model_class: model
        ).execute

        # Handle standalone attributes
        attributes.select { |_name, attr| attr.type == :standalone }.each do |_name, attr|
          attr.prepare(@source)
        end
        @source
      end

      def render_one
        output = {}
        render_attributes output
        render_count_attributes output
        render_relations output
        render_standalone_attributes output

        output
      end

      def render_attributes(output)
        attributes.each do |name, attr|
          next if attr.type == :standalone

          # TODO:
          # Handle options & default value
          output[name] = attr.value source
        end
      end

      def render_relations(output)
        relations.each do |name, relation|
          # TODO:
          # Handle subfields, i.e. blocks
          # Handle default values
          output[name] = relation.value source
        end
      end

      def render_count_attributes(output)
        count_attributes.each do |name, field|
          # TODO: Add "as:" option support
          output["#{name}_count"] = field.value source
        end
      end

      def render_standalone_attributes(output)
        attributes.each do |name, attr|
          next unless attr.type == :standalone

          output[name] = attr.value
        end
      end
    end

    module ClassMethods
      def attribute(name, options = {}, &block)
        attributes[name] = if options[:provider].present?
                             DataPortal::Attributes::Standalone.new(name, options, &block)
                           else
                             DataPortal::Attributes::Standard.new(name, options, &block)
                           end
      end

      def count_attribute(name, _options = {})
        # TODO: Add "as: " to options
        count_attributes[name] = DataPortal::Attributes::Count.new(name)
      end

      def relation(name, options = {}, &block)
        relations[name] = DataPortal::Relations::Standard.new(name, options, &block)
      end

      def model_class(klass)
        self.model = klass
      end
    end
  end
end
