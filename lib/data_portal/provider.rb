# frozen_string_literal: true

module DataPortal
  module Provider
    extend ActiveSupport::Concern
    included do
      attr_accessor :ids, :attributes, :fields, :model_class

      def initialize(ids:, attributes:, fields:, model_class:)
        @ids = ids.is_a?(Array) ? ids : [ids]
        @attributes = attributes
        @fields = fields
        @model_class = model_class
      end

      def execute
        relation = model_class.where("#{model_class.primary_key}": ids)
        relation = relation.includes(relation_fields) if relation_fields.size.positive?

        ids.size == 1 ? relation.first : relation.to_a
      end

      def relation_fields
        fields.map { |_name, field| field.relation }.compact
      end
    end

    module ClassMethods
      def model(klass)
        model_class = klass
      end
    end
  end
end

# # Usage
# class PostProvider
#   include DataPortal::Provider

#   model_class Post
# end

# pp = PostProvider.build(id: id, attributes: attributes, fields: fields)
# pv = PostView
