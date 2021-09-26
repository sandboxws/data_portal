module DataPortal::Relations
  class Standard
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

    def process_block(&block)
      # Process attributes
      # TODO: Add recursive support
      instance_eval(&block)
    end

    def attribute(name, options = {}, &block)
      attributes[name] = DataPortal::Attributes::Standard.new(name, options, &block)
    end

    def count_attribute(name, _options = {})
      count_attributes[name] = DataPortal::Attributes::Count.new(name)
    end

    # TODO: add recursive support
    def value(object)
      value = method_name.present? ? object.send(method_name) : object.send(name)
      return unless value.present?
      return object_value(value) unless value.is_a?(ActiveRecord::Associations::CollectionProxy)

      value = value.order(**order) if order.present?
      value.map do |obj|
        object_value obj
      end
    end

    private

    def object_value(value)
      if value.present? && attributes.size.positive?
        output = {}
        attributes.each do |name, attr|
          output[name] = attr.value value
        end

        # TODO: Refactor to rendering utils
        count_attributes.each do |name, attr|
          output["#{name}_count"] = attr.value value
        end

        value = output
      end
      value = default_value if value.nil? && default_value.present?

      value
    end
  end
end
