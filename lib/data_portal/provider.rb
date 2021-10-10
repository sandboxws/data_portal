# frozen_string_literal: true

module DataPortal
  module Provider
    extend ActiveSupport::Concern
    included do
      attr_accessor :ids, :attributes, :relations, :model_class, :filters, :options, :includes

      # TODO: Add validations
      def initialize(ids:, attributes:, model_class:, relations: [], filters: {}, options: {}, includes: [])
        @ids = ids.is_a?(Array) ? ids : [ids] unless ids.nil?
        @attributes = attributes
        @filters = filters
        @model_class = model_class
        @options = options
        @relations = relations
        @includes = includes
      end

      # TODO: allow executing using filters with no ids
      def execute
        relation = model_class
        relation = model_class.where("#{model_class.primary_key}": ids) unless ids.nil? || ids.size == 0
        relation = relation.includes(includes) unless includes.size.zero?
        relation = apply_filters relation
        # relation = relation.includes(relation_names) if relation_names.size.positive?

        ids.present? && ids.size == 1 ? relation.first : relation.to_a
      end

      # Apply filters, order, and limits
      # TODO: rename function and add arguments support
      def apply_filters(relation)
        return relation unless filters[:main].present?

        # source_reflection_names = {}

        filters.each do |name, filters|
          # source_reflection_names[name] = name
          relation = name == :main ? relation.where(filters) : relation.where("#{name}": filters)
        end

        # Only works when filters are applied
        relations.each do |name, rel|
          next unless rel.has_many? && rel.order.present?

          name = filters[name].present? ? name : model_class.reflect_on_association(name).source_reflection_name
          rel.order.each { |attr, direction| relation = relation.order("#{name}.#{attr} #{direction}") }
        end

        relation
      end

      def relation_names
        # fields.map { |_name, field| field.relation }.compact
        # TODO: handle "relation_name:"
        relations.keys
      end
    end

    module ClassMethods
      def model(klass)
        model_class = klass
      end
    end
  end
end
