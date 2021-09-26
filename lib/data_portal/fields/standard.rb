module DataPortal::Fields
  class Standard
    attr_accessor :default_value, :name, :method_name, :options, :relation, :attributes

    def initialize(name, options = {}, &block)
      @name = name
      @options = options
      @default_value = options[:default_value]
      @method_name = options[:method_name]
      @relation = options[:relation]
      @attributes = {}

      process_block(&block) if block_given?
    end

    def process_block(&block)
      # Process attributes
      # TODO: Add recursive support
      instance_eval(&block)
    end

    def attribute(name, options = {}, &block)
      attributes[name] = DataPortal::Attributes::Standard.new(name, options, &block)
      true
    end

    # TODO: add recursive support
    def value(object)
      value = method_name.present? ? object.send(method_name) : object.send(name)
      return unless value.present?
      return object_value(value) unless value.is_a?(ActiveRecord::Associations::CollectionProxy)

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

        value = output
      end
      value = default_value if value.nil? && default_value.present?

      value
    end
  end
end
