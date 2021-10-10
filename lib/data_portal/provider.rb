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
        relation = apply_filters relation
        relation = relation.includes(includes) unless includes.size.zero?
        # relation = relation.includes(relation_names) if relation_names.size.positive?

        ids.present? && ids.size == 1 ? relation.first : relation.to_a
      end

      def apply_filters(relation)
        return relation unless filters[:main].present?

        filters[:main].each do |filter|
          relation = relation.where(filter)
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
