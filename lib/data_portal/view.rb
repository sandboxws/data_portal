module DataPortal
  module View
    extend ActiveSupport::Concern

    included do
      attr_accessor :ids, :filters, :options, :source, :output, :includes

      class_attribute :attributes
      # class_attribute :count_attributes
      class_attribute :model
      class_attribute :relations
      class_attribute :has_many_relations
      class_attribute :has_one_relations

      self.attributes = {}
      self.relations = {}
      self.has_many_relations = {}
      self.has_one_relations = {}
      # self.count_attributes = {}

      def initialize(ids:, filters: {}, options: {})
        @ids = ids.is_a?(Array) ? ids : [ids]
        @filters = filters
        @options = options
        @includes = {}

        # initialize AR includes
        relations.each do |_name, relation|
          prepare_includes(@includes, relation)
        end
      end

      def render
        ::DataPortal::ViewRenderer.render self, source
      end

      def count_attributes
        @count_attributes ||= attributes.select { |_name, attr| attr.count? }
      end

      def prepare_includes(includes, relation)
        if relation.relations.size.zero?
          includes[relation.name] = {}
        else
          relation.relations.each do |_a_name, a_relation|
            includes[relation.name] = {}
            prepare_includes(includes[relation.name], a_relation)
          end
        end
      end

      def source
        # convention over configuration
        provider_class = "Providers::#{model.name}Provider".constantize
        @source ||= provider_class.new(
          ids: ids,
          attributes: attributes,
          relations: relations,
          model_class: model,
          includes: includes
        ).execute

        # Handle standalone attributes
        attributes.select { |_name, attr| attr.type == :standalone }.each do |_name, attr|
          attr.prepare(@source)
        end

        @source
      end

      def render_relations_bak(output, relation, source)
        name = relation.first
        relation = relation.last
        if relation.relations.size.zero?
          puts "Render relations: #{name} #{source.class.name}:#{source.id}"
          output[name] = relation.value source
        else
          # output[root_name][name] = {}
          # output = output[name]
          source = source.send name
          output[name] = source.is_a?(ActiveRecord::Associations::CollectionProxy) ? [] : {}
          source = source.is_a?(ActiveRecord::Associations::CollectionProxy) ? source : [source]
          source.each_with_index do |source, _idx|
            relation.relations.each do |relation|
              # output[name] = relation.value source
              render_relations output, relation, source
            end
          end
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

      # def count_attribute(name, _options = {})
      #   # TODO: Add "as: " to options
      #   count_attributes[name] = DataPortal::Attributes::Count.new(name)
      # end

      def relation(name, options = {}, &block)
        relations[name] = DataPortal::Relations::Standard.new(name, options, &block)
      end

      def has_many(name, options = {}, &block)
        options[:type] = :has_many
        relations[name] = DataPortal::Relations::Standard.new(name, options, &block)
      end

      def model_class(klass)
        self.model = klass
      end
    end
  end
end
