module DataPortal::Relations
  module Base
    extend ActiveSupport::Concern

    included do
      attr_accessor :default_value,
                    :name,
                    :method_name,
                    :options,
                    :attributes,
                    :order,
                    :count_attributes

      def initialize(name, options = {}, &block)
        @name = name
        @options = options
        @attributes = {}
        @count_attributes = {}
        @default_value = options[:default_value]
        @method_name = options[:method_name]
        @order = options[:order]

        process_block(&block) if block_given?
      end

      def canonical_name
        method_name || name
      end

      def process_block(&block)
        instance_eval(&block)
      end

      def attribute(name, options = {}, &block)
        attributes[name] = DataPortal::Attributes::Standard.new(name, options, &block)
      end
    end
  end
end
