# frozen_string_literal: true

module DataPortal
  module Provider
    extend ActiveSupport::Concern
    included do
      attr_accessor :ids, :attributes, :relations, :model_class, :filters, :options

      # TODO: Add validations
      def initialize(ids:, attributes:, model_class:, relations: [], filters: {}, options: {})
        @ids = ids.is_a?(Array) ? ids : [ids]
        @attributes = attributes
        @filters = filters
        @model_class = model_class
        @options = options
        @relations = relations
      end

      # TODO: allow executing using filters with no ids
      def execute
        relation = model_class.where("#{model_class.primary_key}": ids)
        relation = relation.includes(relation_names) if relation_names.size.positive?

        ids.size == 1 ? relation.first : relation.to_a
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
